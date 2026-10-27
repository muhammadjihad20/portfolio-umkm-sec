-- File: database/schema.sql
CREATE DATABASE IF NOT EXISTS db_umkm_sec;
USE db_umkm_sec;

-- 1. Tabel Users (Untuk uji coba Authentication & Privilege Escalation di hari Rabu)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'umkm_owner', 'auditor') DEFAULT 'umkm_owner',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabel Profil/Unit UMKM (Untuk uji coba Horizontal Access Control)
CREATE TABLE umkm_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    business_name VARCHAR(100) NOT NULL,
    target_url VARCHAR(255) NULL, -- Opsional: jika UMKM punya web untuk di-scan
    risk_score INT DEFAULT 0,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Tabel Catatan Transaksi/Kasbon atau Temuan Audit (Target utama uji IDOR di hari Kamis)
CREATE TABLE ledger_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    umkm_id INT NOT NULL,
    customer_or_issue_name VARCHAR(100) NOT NULL,
    amount_or_severity VARCHAR(50) NOT NULL,
    status ENUM('pending', 'verified', 'resolved') DEFAULT 'pending',
    secret_notes TEXT, -- Data sensitif yang tidak boleh bocor ke UMKM lain
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (umkm_id) REFERENCES umkm_profiles(id) ON DELETE CASCADE
);

-- Insert Dummy Data untuk bahan eksploitasi (2 UMKM berbeda & 1 Admin)
INSERT INTO users (username, email, password_hash, role) VALUES
('admin_master', 'admin@local.test', '$2y$10$DummyHashForAdmin123456789', 'admin'),
('toko_berkah', 'berkah@umkm.test', '$2y$10$DummyHashForUserA123456789', 'umkm_owner'),
('warung_maju', 'maju@umkm.test', '$2y$10$DummyHashForUserB123456789', 'umkm_owner');

INSERT INTO umkm_profiles (owner_id, business_name, target_url, risk_score) VALUES
(2, 'Toko Kelontong Berkah', 'http://berkah-local.test', 25),
(3, 'Warung Maju Jaya', 'http://maju-local.test', 60);

INSERT INTO ledger_records (umkm_id, customer_or_issue_name, amount_or_severity, status, secret_notes) VALUES
(1, 'Kasbon Pelanggan: Budi', 'Rp 500.000', 'pending', 'Rahasia Toko Berkah: Jatuh tempo minggu depan'),
(2, 'Kasbon Pelanggan: Siti', 'Rp 1.250.000', 'verified', 'Rahasia Warung Maju: Jaminan KTP disimpan');