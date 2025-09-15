import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'gene_pos.db';
  static const _databaseVersion = 1;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic as needed
    }
  }

  Future<void> _createTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        profile_image_url TEXT,
        google_id TEXT,
        shop_id INTEGER,
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        pin_hash TEXT
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER DEFAULT 1,
        shop_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        cost_price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL,
        barcode TEXT,
        sku TEXT NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT,
        is_active INTEGER DEFAULT 1,
        shop_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        credit_limit REAL DEFAULT 0.0,
        outstanding_balance REAL DEFAULT 0.0,
        is_active INTEGER DEFAULT 1,
        shop_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY,
        transaction_number TEXT UNIQUE NOT NULL,
        user_id INTEGER NOT NULL,
        customer_id INTEGER,
        subtotal REAL NOT NULL,
        tax_amount REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        total REAL NOT NULL,
        amount_tendered REAL,
        change_amount REAL,
        payment_method TEXT NOT NULL,
        is_credit INTEGER DEFAULT 0,
        shop_id INTEGER,
        timestamp TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Transaction items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        discount_amount REAL DEFAULT 0.0,
        total_price REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY,
        customer_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        notes TEXT,
        transaction_id INTEGER,
        payment_type TEXT DEFAULT 'loan_repayment',
        shop_id INTEGER,
        timestamp TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id),
        FOREIGN KEY (transaction_id) REFERENCES transactions (id)
      )
    ''');

    // Stock adjustments table
    await db.execute('''
      CREATE TABLE stock_adjustments (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        old_quantity INTEGER NOT NULL,
        new_quantity INTEGER NOT NULL,
        reason TEXT NOT NULL,
        notes TEXT,
        user_id INTEGER NOT NULL,
        shop_id INTEGER,
        timestamp TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_products_category ON products(category)',
    );
    await db.execute('CREATE INDEX idx_products_sku ON products(sku)');
    await db.execute(
      'CREATE INDEX idx_transactions_user ON transactions(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_customer ON transactions(customer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_customer ON payments(customer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_stock_adjustments_product ON stock_adjustments(product_id)',
    );
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed initial categories
    final categories = [
      {'name': 'Food & Beverages', 'description': 'Food items and drinks'},
      {'name': 'Household', 'description': 'Household items and supplies'},
      {
        'name': 'Personal Care',
        'description': 'Personal care and hygiene products',
      },
      {
        'name': 'Electronics',
        'description': 'Electronic devices and accessories',
      },
      {'name': 'Clothing', 'description': 'Clothing and fashion items'},
      {'name': 'Others', 'description': 'Miscellaneous items'},
    ];

    for (var category in categories) {
      await db.insert('categories', {
        ...category,
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Database maintenance methods
  Future<void> clearDatabase() async {
    final db = await database;
    await db.execute('DELETE FROM stock_adjustments');
    await db.execute('DELETE FROM payments');
    await db.execute('DELETE FROM transaction_items');
    await db.execute('DELETE FROM transactions');
    await db.execute('DELETE FROM products');
    await db.execute('DELETE FROM customers');
    await db.execute('DELETE FROM categories');
    await db.execute('DELETE FROM users');
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await clearDatabase();
    await _seedInitialData(db);
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sqlite_master WHERE type="table"',
    );
    final tableCount = Sqflite.firstIntValue(result) ?? 0;

    return {
      'database_name': _databaseName,
      'version': _databaseVersion,
      'table_count': tableCount,
      'path': db.path,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
