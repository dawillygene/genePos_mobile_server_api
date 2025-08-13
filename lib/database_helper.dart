import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'gene_pos.db');
    return await openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE password_reset_tokens(
          email TEXT PRIMARY KEY,
          token TEXT NOT NULL,
          created_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE permissions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          guard_name TEXT NOT NULL,
          created_at TEXT,
          updated_at TEXT,
          UNIQUE(name, guard_name)
        )
      ''');

      await db.execute('''
        CREATE TABLE roles(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          team_id INTEGER,
          name TEXT NOT NULL,
          guard_name TEXT NOT NULL,
          created_at TEXT,
          updated_at TEXT,
          UNIQUE(team_id, name, guard_name)
        )
      ''');

      await db.execute('''
        CREATE TABLE model_has_permissions(
          permission_id INTEGER,
          model_type TEXT NOT NULL,
          model_id INTEGER NOT NULL,
          team_id INTEGER,
          PRIMARY KEY(permission_id, model_id, model_type, team_id),
          FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE model_has_roles(
          role_id INTEGER,
          model_type TEXT NOT NULL,
          model_id INTEGER NOT NULL,
          team_id INTEGER,
          PRIMARY KEY(role_id, model_id, model_type, team_id),
          FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE role_has_permissions(
          permission_id INTEGER,
          role_id INTEGER,
          PRIMARY KEY(permission_id, role_id),
          FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
      )
    ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          image TEXT,
          name TEXT NOT NULL,
          description TEXT,
          status INTEGER NOT NULL DEFAULT 1,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE brands(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          image TEXT,
          name TEXT NOT NULL,
          description TEXT,
          status INTEGER NOT NULL DEFAULT 1,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE units(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          short_name TEXT NOT NULL,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          image TEXT,
          name TEXT NOT NULL,
          slug TEXT UNIQUE NOT NULL,
          sku TEXT UNIQUE NOT NULL,
          description TEXT,
          category_id INTEGER,
          brand_id INTEGER,
          unit_id INTEGER,
          price REAL DEFAULT 0,
          discount REAL DEFAULT 0,
          discount_type TEXT DEFAULT 'fixed',
          purchase_price REAL DEFAULT 0,
          quantity INTEGER DEFAULT 0,
          expire_date TEXT,
          status INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
          FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
          FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE SET NULL
        )
      ''');
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE pos_carts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          quantity INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE customers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT UNIQUE,
          address TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE orders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          customer_id INTEGER NOT NULL,
          discount REAL DEFAULT 0,
          sub_total REAL DEFAULT 0,
          total REAL DEFAULT 0,
          paid REAL DEFAULT 0,
          due REAL DEFAULT 0,
          note TEXT,
          is_returned INTEGER DEFAULT 0,
          status INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE order_products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER DEFAULT 1,
          price REAL DEFAULT 0,
          purchase_price REAL DEFAULT 0,
          discount REAL DEFAULT 0,
          sub_total REAL DEFAULT 0,
          total REAL DEFAULT 0,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE order_transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL UNSIGNED,
          order_id INTEGER NOT NULL,
          customer_id INTEGER NOT NULL,
          user_id INTEGER,
          paid_by TEXT,
          transaction_id TEXT,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
          FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE suppliers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT UNIQUE,
          address TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE purchases(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          supplier_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          sub_total REAL DEFAULT 0,
          tax REAL DEFAULT 0,
          discount_value REAL DEFAULT 0,
          discount_type TEXT DEFAULT 'fixed',
          shipping REAL DEFAULT 0,
          grand_total REAL DEFAULT 0,
          status INTEGER,
          date TEXT,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE purchase_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          purchase_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          purchase_price REAL DEFAULT 0,
          price REAL DEFAULT 0,
          quantity INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE currencies(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          code TEXT UNIQUE NOT NULL,
          symbol TEXT NOT NULL,
          active INTEGER DEFAULT 0,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
      await db.execute('ALTER TABLE products ADD COLUMN discount REAL');
      await db.execute('ALTER TABLE products ADD COLUMN discount_type TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        email_verified_at TEXT,
        password TEXT NOT NULL,
        remember_token TEXT,
        username TEXT UNIQUE NOT NULL,
        profile_image TEXT,
        google_id TEXT,
        is_google_registered INTEGER NOT NULL DEFAULT 0,
        is_suspended INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE password_reset_tokens(
        email TEXT PRIMARY KEY,
        token TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE permissions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        guard_name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        UNIQUE(name, guard_name)
      )
    ''');

    await db.execute('''
      CREATE TABLE roles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        team_id INTEGER,
        name TEXT NOT NULL,
        guard_name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        UNIQUE(team_id, name, guard_name)
      )
    ''');

    await db.execute('''
      CREATE TABLE model_has_permissions(
        permission_id INTEGER,
        model_type TEXT NOT NULL,
        model_id INTEGER NOT NULL,
        team_id INTEGER,
        PRIMARY KEY(permission_id, model_id, model_type, team_id),
        FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE model_has_roles(
        role_id INTEGER,
        model_type TEXT NOT NULL,
        model_id INTEGER NOT NULL,
        team_id INTEGER,
        PRIMARY KEY(role_id, model_id, model_type, team_id),
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE role_has_permissions(
        permission_id INTEGER,
        role_id INTEGER,
        PRIMARY KEY(permission_id, role_id),
        FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image TEXT,
        name TEXT NOT NULL,
        description TEXT,
        status INTEGER NOT NULL DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image TEXT,
        name TEXT NOT NULL,
        description TEXT,
        status INTEGER NOT NULL DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE units(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        short_name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image TEXT,
        name TEXT NOT NULL,
        slug TEXT UNIQUE NOT NULL,
        sku TEXT UNIQUE NOT NULL,
        description TEXT,
        category_id INTEGER,
        brand_id INTEGER,
        unit_id INTEGER,
        price REAL DEFAULT 0,
        discount REAL DEFAULT 0,
        discount_type TEXT DEFAULT 'fixed',
        purchase_price REAL DEFAULT 0,
        quantity INTEGER DEFAULT 0,
        expire_date TEXT,
        status INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
        FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
        FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pos_carts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT UNIQUE,
        address TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        discount REAL DEFAULT 0,
        sub_total REAL DEFAULT 0,
        total REAL DEFAULT 0,
        paid REAL DEFAULT 0,
        due REAL DEFAULT 0,
        note TEXT,
        is_returned INTEGER DEFAULT 0,
        status INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE order_products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        price REAL DEFAULT 0,
        purchase_price REAL DEFAULT 0,
        discount REAL DEFAULT 0,
        sub_total REAL DEFAULT 0,
        total REAL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE order_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL UNSIGNED,
        order_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        user_id INTEGER,
        paid_by TEXT,
        transaction_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT UNIQUE,
        address TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE purchases(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        sub_total REAL DEFAULT 0,
        tax REAL DEFAULT 0,
        discount_value REAL DEFAULT 0,
        discount_type TEXT DEFAULT 'fixed',
        shipping REAL DEFAULT 0,
        grand_total REAL DEFAULT 0,
        status INTEGER,
        date TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE purchase_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        purchase_price REAL DEFAULT 0,
        price REAL DEFAULT 0,
        quantity INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE currencies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        symbol TEXT NOT NULL,
        active INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.insert('currencies', {
      'name': 'Tanzanian Shilling',
      'code': 'Tsh',
      'symbol': 'Tsh',
      'active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
