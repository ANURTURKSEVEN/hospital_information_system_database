CREATE DATABASE IF NOT EXISTS hastane_bilgi_sistemi;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

USE hastane_bilgi_sistemi;

-- Hastane bilgileri : 
CREATE TABLE IF NOT EXISTS brans (
    brans_id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(50) NOT NULL UNIQUE,
    gorev_tanimi TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS doktor (
    doktor_id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    unvan VARCHAR(50),
    brans_id INT NOT NULL,
    telefon VARCHAR(11),
    eposta VARCHAR(150),
    aktif BOOLEAN DEFAULT TRUE,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (brans_id) REFERENCES brans(brans_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS poliklinik (
    poliklinik_id INT AUTO_INCREMENT PRIMARY KEY,
    brans_id INT NOT NULL,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    poliklinik_no VARCHAR(255),
    FOREIGN KEY (brans_id) REFERENCES brans(brans_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS klinik (
    klinik_id INT AUTO_INCREMENT PRIMARY KEY,
    brans_id INT NOT NULL,
    ad VARCHAR(50) NOT NULL,
    klinik_no VARCHAR(255),
    FOREIGN KEY (brans_id) REFERENCES brans(brans_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS randevu (
    randevu_id INT AUTO_INCREMENT PRIMARY KEY,
    hasta_id INT NOT NULL,
    poliklinik_id INT NOT NULL,
    doktor_id INT NOT NULL,
    randevu_tarihi DATETIME NOT NULL,
    sure_dakika INT DEFAULT 10,
    durum ENUM('BEKLEMEDE','ONAYLANDI','TAMAMLANDI','IPTAL','GELMEDI') DEFAULT 'BEKLEMEDE',
    notlar TEXT,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hasta_id) REFERENCES hasta(hasta_id),
    FOREIGN KEY (poliklinik_id) REFERENCES poliklinik(poliklinik_id),
    FOREIGN KEY (doktor_id) REFERENCES doktor(doktor_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS personel (
    personel_id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    gorev VARCHAR(100) NOT NULL,
    departman VARCHAR(100),
    telefon VARCHAR(11),
    eposta VARCHAR(150),
    aktif BOOLEAN DEFAULT TRUE,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Hasta bilgileri : 
CREATE TABLE IF NOT EXISTS hasta (
    hasta_id INT AUTO_INCREMENT PRIMARY KEY,
    tc_no CHAR(11) NOT NULL UNIQUE,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    dogum_tarihi DATE,
    cinsiyet ENUM('ERKEK','KADIN','DIGER'),
    telefon VARCHAR(11),
    adres TEXT,
    kan_grubu VARCHAR(5),
    saglik_sigortasi VARCHAR(150),
    birim ENUM('POLIKLINIK','KLINIK','ACIL') NOT NULL,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tehsis(
    tehsis_id INT AUTO_INCREMENT PRIMARY KEY,
    hasta_id INT NOT NULL,
    doktor_id INT NOT NULL,
    tahlil_sonuc TEXT,
    tehsis TEXT,
    FOREIGN KEY (doktor_id) REFERENCES doktor(doktor_id),
    FOREIGN KEY (hasta_id) REFERENCES hasta(hasta_id)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tedavi (
    tedavi_id INT AUTO_INCREMENT PRIMARY KEY,
    tehsis_id INT NOT NULL,
    birim ENUM('POLIKLINIK','KLINIK','ACIL') NOT NULL,
	klinik_id INT NOT NULL,
    FOREIGN KEY (klinik_id) REFERENCES klinik(klinik_id),
    FOREIGN KEY (tehsis_id) REFERENCES tehsis(tehsis_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS oda (
    oda_id INT AUTO_INCREMENT PRIMARY KEY,
    klinik_id INT NOT NULL,
    oda_no VARCHAR(50) NOT NULL,
    yatak_sayisi INT DEFAULT 1,
    aciklama TEXT,
    UNIQUE (klinik_id, oda_no),
    FOREIGN KEY (klinik_id) REFERENCES klinik(klinik_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS yatili_tedavi(
    yatili_tedavi_id INT AUTO_INCREMENT PRIMARY KEY,
    tehsis_id INT NOT NULL,
	sevk_eden_doktor_id INT NULL,
    sorumlu_doktor_id INT NULL,
    yatisa_giris DATETIME NOT NULL,
    cikis_tarihi DATETIME NULL,
     yatis_id INT NOT NULL,
    oda_id INT NOT NULL,
    yatak_no VARCHAR(20),
    baslangic_tarihi DATETIME NOT NULL,
    bitis_tarihi DATETIME NULL,
    gunluk_ucret DECIMAL(12,2) DEFAULT 0,
    durum ENUM('AKTIF','TABURCU','TRANSFER','VEFAT') DEFAULT 'AKTIF',
    notlar TEXT,
    FOREIGN KEY (yatis_id) REFERENCES yatis(yatis_id),
    FOREIGN KEY (oda_id) REFERENCES oda(oda_id),
    FOREIGN KEY (sevk_eden_doktor_id) REFERENCES doktor(doktor_id),
    FOREIGN KEY (sorumlu_doktor_id) REFERENCES doktor(doktor_id),
    FOREIGN KEY (tehsis_id) REFERENCES tehsis(tehsis_id)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recete (
    recete_id INT AUTO_INCREMENT PRIMARY KEY,
    doktor_id INT NOT NULL,
    hasta_id INT NOT NULL,
    tedavi_id INT NOT NULL,
    recete_id INT NOT NULL,
    ilac_id INT NOT NULL,
    doz VARCHAR(80),
    kullanim_sikligi VARCHAR(80),
    gun_sayisi INT DEFAULT 1,
    kullanim_talimati TEXT,
    ilac_ucreti DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (doktor_id) REFERENCES doktor(doktor_id),
    FOREIGN KEY (hasta_id) REFERENCES hasta(hasta_id),
    FOREIGN KEY (tedavi_id) REFERENCES tedavi(tedavi_id),
    FOREIGN KEY (recete_id) REFERENCES recete(recete_id),
    FOREIGN KEY (ilac_id) REFERENCES ilac(ilac_id)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS ilac (
    ilac_id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(200) NOT NULL,
    tur VARCHAR(100),
    etken_madde VARCHAR(255),
    fiyat DECIMAL(12,2) NOT NULL,
    para_birimi CHAR(3) DEFAULT 'TRY',
    baslangic_tarihi DATE NOT NULL,
    bitis_tarihi DATE NULL,
    aciklama TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tahlil (
    tahlil_id INT AUTO_INCREMENT PRIMARY KEY,
    hasta_id INT NOT NULL,
    doktor_id INT NULL,
    istek_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP,
    tahlil_turu VARCHAR(150) NOT NULL,
    oncelik ENUM('RUTIN','ACIL') DEFAULT 'RUTIN',
    tahlil_sonuc TEXT,
    notlar TEXT,
    FOREIGN KEY (hasta_id) REFERENCES hasta(hasta_id),
    FOREIGN KEY (doktor_id) REFERENCES doktor(doktor_id)
) ENGINE=InnoDB;

 -- Ücretlendirme : 
 
CREATE TABLE IF NOT EXISTS odeme_pol (
    odeme_pol_id INT AUTO_INCREMENT PRIMARY KEY,
    poliklinik_id INT NOT NULL,
    ucret DECIMAL(12,2) NOT NULL,
    para_birimi CHAR(3) DEFAULT 'TRY',
    baslangic_tarihi DATE NOT NULL,
    bitis_tarihi DATE NULL,
    FOREIGN KEY (poliklinik_id) REFERENCES poliklinik(poliklinik_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ucret_tedavi (
    ucret_id INT AUTO_INCREMENT PRIMARY KEY,
    tedavi_turu VARCHAR(150) NOT NULL,
    ucret DECIMAL(12,2) NOT NULL,
    para_birimi CHAR(3) DEFAULT 'TRY',
    aciklama TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ucret_oda (
    ucret_id INT AUTO_INCREMENT PRIMARY KEY,
    oda_id INT NOT NULL,
    gunluk_ucret DECIMAL(12,2) NOT NULL,
    para_birimi CHAR(3) DEFAULT 'TRY',
    baslangic_tarihi DATE NOT NULL,
    bitis_tarihi DATE NULL,
    FOREIGN KEY (oda_id) REFERENCES oda(oda_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ucret_tahlil (
    ucret_id INT AUTO_INCREMENT PRIMARY KEY,
    tahlil_turu VARCHAR(150) NOT NULL,
    ucret DECIMAL(12,2) NOT NULL,
    para_birimi CHAR(3) DEFAULT 'TRY',
    aciklama TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fatura (
    fatura_id INT AUTO_INCREMENT PRIMARY KEY,
    hasta_id INT NOT NULL,
    fatura_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP,
    toplam_tutar DECIMAL(12,2) DEFAULT 0,
    odenen_tutar DECIMAL(12,2) DEFAULT 0,
    durum ENUM('TASLAK','KESILDI','ODEME_ALINDI','IPTAL') DEFAULT 'TASLAK',
    notlar TEXT,
    FOREIGN KEY (hasta_id) REFERENCES hasta(hasta_id)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;