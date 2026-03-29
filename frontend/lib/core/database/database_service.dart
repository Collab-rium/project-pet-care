import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'pet_care.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Pets table  
    await db.execute('''
      CREATE TABLE pets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT,
        birth_date TEXT,
        weight REAL,
        gender TEXT,
        photo_url TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        pet_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        reminder_type TEXT NOT NULL,
        reminder_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (pet_id) REFERENCES pets (id)
      )
    ''');

    // Weight records table
    await db.execute('''
      CREATE TABLE weight_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        pet_id TEXT NOT NULL,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (pet_id) REFERENCES pets (id)
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        pet_id TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (pet_id) REFERENCES pets (id)
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        pet_id TEXT NOT NULL,
        monthly_limit REAL NOT NULL,
        current_spent REAL NOT NULL DEFAULT 0,
        month TEXT NOT NULL,
        year INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (pet_id) REFERENCES pets (id)
      )
    ''');

    // Photos table
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        pet_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        thumbnail_path TEXT,
        caption TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (pet_id) REFERENCES pets (id)
      )
    ''');

    // Albums table
    await db.execute('''
      CREATE TABLE albums (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        cover_photo_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_pets_user_id ON pets (user_id)');
    await db.execute('CREATE INDEX idx_reminders_user_id ON reminders (user_id)');
    await db.execute('CREATE INDEX idx_reminders_pet_id ON reminders (pet_id)');
    await db.execute('CREATE INDEX idx_weight_records_pet_id ON weight_records (pet_id)');
    await db.execute('CREATE INDEX idx_expenses_pet_id ON expenses (pet_id)');
    await db.execute('CREATE INDEX idx_photos_pet_id ON photos (pet_id)');

    // Insert seed data
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Create demo user
    await db.insert('users', {
      'id': 'user-1',
      'username': 'demo',
      'password_hash': r'$2a$10$K1wNZ5sHgU.JKF7W8lR6yubVVN7ZUoC9VdJJ4G0XtNkY9Lw6BfK4G', // password: demo123
      'created_at': now,
      'updated_at': now,
    });

    // Create demo pets
    await db.insert('pets', {
      'id': 'pet-1',
      'user_id': 'user-1',
      'name': 'Buddy',
      'species': 'Dog',
      'breed': 'Golden Retriever',
      'birth_date': '2020-03-15',
      'weight': 32.5,
      'gender': 'Male',
      'notes': 'Very friendly and energetic. Loves playing fetch.',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('pets', {
      'id': 'pet-2',
      'user_id': 'user-1',
      'name': 'Whiskers',
      'species': 'Cat',
      'breed': 'Persian',
      'birth_date': '2019-07-22',
      'weight': 4.2,
      'gender': 'Female',
      'notes': 'Indoor cat. Very calm and loves sleeping.',
      'created_at': now,
      'updated_at': now,
    });

    // Create demo reminders
    final tomorrow = DateTime.now().add(Duration(days: 1)).toIso8601String();
    final nextWeek = DateTime.now().add(Duration(days: 7)).toIso8601String();
    final yesterday = DateTime.now().subtract(Duration(days: 1)).toIso8601String();

    await db.insert('reminders', {
      'id': 'reminder-1',
      'user_id': 'user-1',
      'pet_id': 'pet-1',
      'title': 'Vet Appointment',
      'description': 'Annual checkup with Dr. Smith',
      'reminder_type': 'Vet',
      'reminder_date': nextWeek,
      'is_completed': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('reminders', {
      'id': 'reminder-2',
      'user_id': 'user-1',
      'pet_id': 'pet-2',
      'title': 'Medication',
      'description': 'Give flea medication',
      'reminder_type': 'Medicine',
      'reminder_date': tomorrow,
      'is_completed': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('reminders', {
      'id': 'reminder-3',
      'user_id': 'user-1',
      'pet_id': 'pet-1',
      'title': 'Grooming',
      'description': 'Monthly grooming appointment',
      'reminder_type': 'Grooming',
      'reminder_date': yesterday,
      'is_completed': 0,
      'created_at': now,
      'updated_at': now,
    });

    // Create demo weight records
    final dates = [
      DateTime.now().subtract(Duration(days: 30)),
      DateTime.now().subtract(Duration(days: 20)),
      DateTime.now().subtract(Duration(days: 10)),
      DateTime.now(),
    ];

    final weights = [31.5, 32.0, 32.2, 32.5];
    
    for (int i = 0; i < dates.length; i++) {
      await db.insert('weight_records', {
        'id': 'weight-$i',
        'user_id': 'user-1',
        'pet_id': 'pet-1',
        'weight': weights[i],
        'date': dates[i].toIso8601String(),
        'notes': i == 3 ? 'Looking healthy!' : null,
        'created_at': now,
        'updated_at': now,
      });
    }

    // Create demo expenses
    await db.insert('expenses', {
      'id': 'expense-1',
      'user_id': 'user-1',
      'pet_id': 'pet-1',
      'amount': 65.00,
      'category': 'Vet',
      'description': 'Vaccination boosters',
      'date': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('expenses', {
      'id': 'expense-2',
      'user_id': 'user-1',
      'pet_id': 'pet-1',
      'amount': 28.50,
      'category': 'Food',
      'description': 'Premium dog food',
      'date': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('expenses', {
      'id': 'expense-3',
      'user_id': 'user-1',
      'pet_id': 'pet-2',
      'amount': 15.00,
      'category': 'Toys',
      'description': 'Cat toys and treats',
      'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'created_at': now,
      'updated_at': now,
    });

    // Create demo budget
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    await db.insert('budgets', {
      'id': 'budget-1',
      'user_id': 'user-1',
      'pet_id': 'pet-1',
      'monthly_limit': 200.00,
      'current_spent': 93.50,
      'month': currentMonth.toString().padLeft(2, '0'),
      'year': currentYear,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('budgets', {
      'id': 'budget-2',
      'user_id': 'user-1',
      'pet_id': 'pet-2',
      'monthly_limit': 100.00,
      'current_spent': 15.00,
      'month': currentMonth.toString().padLeft(2, '0'),
      'year': currentYear,
      'created_at': now,
      'updated_at': now,
    });

    // Create default settings
    await db.insert('settings', {
      'id': 'setting-1',
      'user_id': 'user-1',
      'key': 'theme',
      'value': 'warm',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('settings', {
      'id': 'setting-2',
      'user_id': 'user-1',
      'key': 'dark_mode',
      'value': 'false',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('settings', {
      'id': 'setting-3',
      'user_id': 'user-1',
      'key': 'notifications_enabled',
      'value': 'true',
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'pet_care.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}