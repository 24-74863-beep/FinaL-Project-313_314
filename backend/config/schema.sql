-- Bobby's Motorcycle Repair System - MySQL / MariaDB schema
-- The server (backend/config/db.js) creates the database and runs this file on start-up.
-- Manual setup (phpMyAdmin or mysql CLI): CREATE DATABASE bobbys_repair CHARACTER SET utf8mb4; USE bobbys_repair; then run this file.
-- Timestamps are stored as ISO-8601 text (e.g. 2026-11-20T08:05:00.000Z) because the app sorts and groups them as strings.
-- `extra` stores fields that do not have a dedicated column yet.

CREATE TABLE IF NOT EXISTS customers (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  phone      VARCHAR(20)  NOT NULL DEFAULT '',
  address    VARCHAR(255) NOT NULL DEFAULT '',
  email      VARCHAR(120) NOT NULL DEFAULT '',
  user_id    INT UNSIGNED NULL,
  created_at VARCHAR(30)  NOT NULL,
  extra      JSON NULL,
  KEY ix_customers_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- customers.user_id references users but has no foreign key, to avoid a circular dependency between the two tables
CREATE TABLE IF NOT EXISTS users (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role        VARCHAR(20)  NOT NULL,
  name        VARCHAR(120) NOT NULL,
  username    VARCHAR(60)  NOT NULL,
  pass_hash   CHAR(64)     NOT NULL,
  phone       VARCHAR(20)  NOT NULL DEFAULT '',
  customer_id INT UNSIGNED NULL,
  created_at  VARCHAR(30)  NOT NULL,
  extra       JSON NULL,
  UNIQUE KEY uq_users_username (username),
  CONSTRAINT fk_users_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mechanics (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  phone      VARCHAR(20)  NOT NULL DEFAULT '',
  skills     JSON NOT NULL,
  created_at VARCHAR(30)  NOT NULL,
  extra      JSON NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS motorcycles (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  brand       VARCHAR(60)  NOT NULL,
  model       VARCHAR(60)  NOT NULL,
  plate       VARCHAR(20)  NOT NULL,
  type        VARCHAR(30)  NOT NULL DEFAULT 'Other',
  created_at  VARCHAR(30)  NOT NULL,
  extra       JSON NULL,
  UNIQUE KEY uq_motorcycles_plate (plate),
  CONSTRAINT fk_moto_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS services (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  price      DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at VARCHAR(30)  NOT NULL,
  extra      JSON NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS parts (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  price      DECIMAL(10,2) NOT NULL DEFAULT 0,
  stock      INT NOT NULL DEFAULT 0,
  created_at VARCHAR(30)  NOT NULL,
  extra      JSON NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Services and parts used on a job are stored as JSON snapshots (name and price at the time) so past jobs keep their original prices
CREATE TABLE IF NOT EXISTS repairs (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  motorcycle_id  INT UNSIGNED NOT NULL,
  customer_id    INT UNSIGNED NOT NULL,
  problem        TEXT NOT NULL,
  mechanic_id    INT UNSIGNED NULL,
  status         VARCHAR(30) NOT NULL DEFAULT 'Waiting',
  is_emergency   TINYINT(1)  NOT NULL DEFAULT 0,
  services       JSON NOT NULL,
  parts          JSON NOT NULL,
  notes          TEXT NOT NULL,
  requested      TINYINT(1)  NOT NULL DEFAULT 0,
  preferred_date VARCHAR(10) NOT NULL DEFAULT '',
  created_at     VARCHAR(30) NOT NULL,
  updated_at     VARCHAR(30) NOT NULL DEFAULT '',
  extra          JSON NULL,
  KEY ix_repairs_mechanic_day (mechanic_id, created_at),
  KEY ix_repairs_status (status),
  CONSTRAINT fk_repairs_moto     FOREIGN KEY (motorcycle_id) REFERENCES motorcycles(id),
  CONSTRAINT fk_repairs_customer FOREIGN KEY (customer_id)   REFERENCES customers(id),
  CONSTRAINT fk_repairs_mechanic FOREIGN KEY (mechanic_id)   REFERENCES mechanics(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS emergencies (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id   INT UNSIGNED NULL,
  contact_name  VARCHAR(120) NOT NULL,
  phone         VARCHAR(20)  NOT NULL,
  motorcycle_id INT UNSIGNED NULL,
  moto_info     VARCHAR(255) NOT NULL DEFAULT '',
  location      VARCHAR(255) NOT NULL,
  problem       TEXT NOT NULL,
  urgency       VARCHAR(20)  NOT NULL DEFAULT 'Low',
  status        VARCHAR(20)  NOT NULL DEFAULT 'Pending',
  mechanic_id   INT UNSIGNED NULL,
  repair_id     INT UNSIGNED NULL,
  created_at    VARCHAR(30)  NOT NULL,
  extra         JSON NULL,
  KEY ix_emergencies_status (status),
  CONSTRAINT fk_em_customer FOREIGN KEY (customer_id)   REFERENCES customers(id)   ON DELETE SET NULL,
  CONSTRAINT fk_em_moto     FOREIGN KEY (motorcycle_id) REFERENCES motorcycles(id) ON DELETE SET NULL,
  CONSTRAINT fk_em_mechanic FOREIGN KEY (mechanic_id)   REFERENCES mechanics(id)   ON DELETE SET NULL,
  CONSTRAINT fk_em_repair   FOREIGN KEY (repair_id)     REFERENCES repairs(id)     ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payments (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  repair_id  INT UNSIGNED NOT NULL,
  amount     DECIMAL(10,2) NOT NULL,
  method     VARCHAR(30)  NOT NULL,
  date       VARCHAR(10)  NOT NULL,
  note       VARCHAR(255) NOT NULL DEFAULT '',
  created_at VARCHAR(30)  NOT NULL,
  extra      JSON NULL,
  KEY ix_payments_date (date),
  CONSTRAINT fk_pay_repair FOREIGN KEY (repair_id) REFERENCES repairs(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
