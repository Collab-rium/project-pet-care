import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';
import '../models/models.dart';

class PetRepository {
  final DatabaseService _db = DatabaseService();

  Future<List<Pet>> getUserPets(String userId) async {
    final database = await _db.database;
    final results = await database.query(
      'pets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => Pet.fromMap(map)).toList();
  }

  Future<Pet?> getPetById(String petId) async {
    final database = await _db.database;
    final results = await database.query(
      'pets',
      where: 'id = ?',
      whereArgs: [petId],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Pet.fromMap(results.first);
    }
    return null;
  }

  Future<Pet> createPet(Pet pet) async {
    final database = await _db.database;
    await database.insert('pets', pet.toMap());
    return pet;
  }

  Future<Pet> updatePet(Pet pet) async {
    final database = await _db.database;
    await database.update(
      'pets',
      pet.toMap(),
      where: 'id = ?',
      whereArgs: [pet.id],
    );
    return pet;
  }

  Future<void> deletePet(String petId) async {
    final database = await _db.database;
    await database.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [petId],
    );
  }
}

class ReminderRepository {
  final DatabaseService _db = DatabaseService();

  Future<List<Reminder>> getUserReminders(String userId, {String? petId}) async {
    final database = await _db.database;
    
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];
    
    if (petId != null) {
      whereClause += ' AND pet_id = ?';
      whereArgs.add(petId);
    }
    
    final results = await database.query(
      'reminders',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'reminder_date ASC',
    );
    return results.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getOverdueReminders(String userId) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();
    final results = await database.query(
      'reminders',
      where: 'user_id = ? AND reminder_date < ? AND is_completed = 0',
      whereArgs: [userId, now],
      orderBy: 'reminder_date ASC',
    );
    return results.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getTodayReminders(String userId) async {
    final database = await _db.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    
    final results = await database.query(
      'reminders',
      where: 'user_id = ? AND reminder_date BETWEEN ? AND ?',
      whereArgs: [userId, startOfDay, endOfDay],
      orderBy: 'reminder_date ASC',
    );
    return results.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<Reminder> createReminder(Reminder reminder) async {
    final database = await _db.database;
    await database.insert('reminders', reminder.toMap());
    return reminder;
  }

  Future<Reminder> updateReminder(Reminder reminder) async {
    final database = await _db.database;
    await database.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
    return reminder;
  }

  Future<void> deleteReminder(String reminderId) async {
    final database = await _db.database;
    await database.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  Future<Map<String, int>> getDashboardStats(String userId) async {
    final database = await _db.database;
    
    // Get completed count
    final completedResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM reminders WHERE user_id = ? AND is_completed = 1',
      [userId],
    );
    final completedCount = completedResult.first['count'] as int;
    
    // Get pending count  
    final pendingResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM reminders WHERE user_id = ? AND is_completed = 0 AND reminder_date >= ?',
      [userId, DateTime.now().toIso8601String()],
    );
    final pendingCount = pendingResult.first['count'] as int;
    
    // Get overdue count
    final overdueResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM reminders WHERE user_id = ? AND is_completed = 0 AND reminder_date < ?',
      [userId, DateTime.now().toIso8601String()],
    );
    final overdueCount = overdueResult.first['count'] as int;
    
    return {
      'completed': completedCount,
      'pending': pendingCount,
      'overdue': overdueCount,
    };
  }
}

class WeightRepository {
  final DatabaseService _db = DatabaseService();

  Future<List<WeightRecord>> getPetWeightRecords(String petId) async {
    final database = await _db.database;
    final results = await database.query(
      'weight_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'date DESC',
    );
    return results.map((map) => WeightRecord.fromMap(map)).toList();
  }

  Future<WeightRecord> createWeightRecord(WeightRecord record) async {
    final database = await _db.database;
    await database.insert('weight_records', record.toMap());
    return record;
  }

  Future<WeightRecord> updateWeightRecord(WeightRecord record) async {
    final database = await _db.database;
    await database.update(
      'weight_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
    return record;
  }

  Future<void> deleteWeightRecord(String recordId) async {
    final database = await _db.database;
    await database.delete(
      'weight_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }
}

class ExpenseRepository {
  final DatabaseService _db = DatabaseService();

  Future<List<Expense>> getPetExpenses(String petId, {String? category}) async {
    final database = await _db.database;
    
    String whereClause = 'pet_id = ?';
    List<dynamic> whereArgs = [petId];
    
    if (category != null) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }
    
    final results = await database.query(
      'expenses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return results.map((map) => Expense.fromMap(map)).toList();
  }

  Future<double> getPetMonthlyExpenses(String petId, int year, int month) async {
    final database = await _db.database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    
    final result = await database.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE pet_id = ? AND date BETWEEN ? AND ?',
      [petId, startDate, endDate],
    );
    
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<Expense> createExpense(Expense expense) async {
    final database = await _db.database;
    await database.insert('expenses', expense.toMap());
    return expense;
  }

  Future<Expense> updateExpense(Expense expense) async {
    final database = await _db.database;
    await database.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    return expense;
  }

  Future<void> deleteExpense(String expenseId) async {
    final database = await _db.database;
    await database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }

  Future<Map<String, double>> getCategoryTotals(String petId, int year, int month) async {
    final database = await _db.database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    
    final results = await database.rawQuery(
      'SELECT category, SUM(amount) as total FROM expenses WHERE pet_id = ? AND date BETWEEN ? AND ? GROUP BY category',
      [petId, startDate, endDate],
    );
    
    Map<String, double> categoryTotals = {};
    for (var result in results) {
      categoryTotals[result['category'] as String] = (result['total'] as double?) ?? 0.0;
    }
    
    return categoryTotals;
  }
}

class BudgetRepository {
  final DatabaseService _db = DatabaseService();

  Future<List<Budget>> getPetBudgets(String petId) async {
    final database = await _db.database;
    final results = await database.query(
      'budgets',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'year DESC, month DESC',
    );
    return results.map((map) => Budget.fromMap(map)).toList();
  }

  Future<Budget?> getCurrentBudget(String petId) async {
    final database = await _db.database;
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;
    
    final results = await database.query(
      'budgets',
      where: 'pet_id = ? AND month = ? AND year = ?',
      whereArgs: [petId, month, year],
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return Budget.fromMap(results.first);
    }
    return null;
  }

  Future<Budget> createBudget(Budget budget) async {
    final database = await _db.database;
    await database.insert('budgets', budget.toMap());
    return budget;
  }

  Future<Budget> updateBudget(Budget budget) async {
    final database = await _db.database;
    await database.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
    return budget;
  }

  Future<void> deleteBudget(String budgetId) async {
    final database = await _db.database;
    await database.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }
}