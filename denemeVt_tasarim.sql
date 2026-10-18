// ==========================================
// 1. KULLANICI VE ROLLER (Kimlik Yönetimi)
// ==========================================
Table Kullanici {
  KullaniciID int [pk, increment]
  Email varchar(100) [unique, not null]
  SifreHash varchar(255) [not null]
  Rol varchar(20) [not null, note: "'YONETICI', 'RESEPSIYON', 'MISAFIR'"]
  OlusturulmaTarihi datetime [default: `CURRENT_TIMESTAMP`]
  
  indexes {
    Email [name: 'idx_kullanici_email'] // Hoca'nın istediği e-posta indeksi
  }
}

Table Misafir {
  MisafirID int [pk, increment]
  KullaniciID int [unique, ref: - Kullanici.KullaniciID] // 1-1 İlişki
  Ad varchar(50) [not null]
  Soyad varchar(50) [not null]
  TCKimlikPasaport varchar(20) [unique]
  Telefon varchar(20)
}

Table Personel {
  PersonelID int [pk, increment]
  KullaniciID int [unique, ref: - Kullanici.KullaniciID] // 1-1 İlişki
  Ad varchar(50) [not null]
  Soyad varchar(50) [not null]
  Departman varchar(50)
  Maas decimal(10,2)
}

// ==========================================
// 2. ODA VE FİYATLANDIRMA (3NF Yapısı)
// ==========================================
Table OdaTipi {
  OdaTipiID int [pk, increment]
  TipAdi varchar(50) [not null]
  YatakSayisi int [not null]
  Kapasite int [not null]
  Aciklama text
}

Table Oda {
  OdaID int [pk, increment]
  OdaTipiID int [ref: > OdaTipi.OdaTipiID]
  OdaNumarasi varchar(10) [unique, not null]
  Kat int
  Durum varchar(20) [not null, default: 'BOS', note: "'BOS', 'DOLU', 'TEMIZLIKTE'"]

  indexes {
    OdaNumarasi [name: 'idx_oda_numarasi'] // Hoca'nın istediği oda numarası indeksi
  }
}

Table SezonFiyati {
  SezonFiyatiID int [pk, increment]
  OdaTipiID int [ref: > OdaTipi.OdaTipiID]
  BaslangicTarihi date [not null]
  BitisTarihi date [not null]
  Fiyat decimal(10,2) [not null] // Fiyat odaya değil, Oda Tipine ve Sezona bağlıdır.
}

// ==========================================
// 3. ÇEKİRDEK İŞ SÜREÇLERİ
// ==========================================
Table Rezervasyon {
  RezervasyonID int [pk, increment]
  MisafirID int [ref: > Misafir.MisafirID]
  OdaID int [ref: > Oda.OdaID]
  GirisTarihi date [not null]
  CikisTarihi date [not null]
  Durum varchar(20) [not null, default: 'ONAYLANDI', note: "'ONAYLANDI', 'IPTAL', 'TAMAMLANDI'"]
  OlusturulmaTarihi datetime [default: `CURRENT_TIMESTAMP`]

  indexes {
    (GirisTarihi, CikisTarihi) [name: 'idx_rezervasyon_tarihleri'] // Hoca'nın istediği tarih aralığı indeksi
  }
}

Table Konaklama {
  KonaklamaID int [pk, increment]
  RezervasyonID int [unique, ref: - Rezervasyon.RezervasyonID] // 1-1 İlişki
  CheckInTarihi datetime [not null, default: `CURRENT_TIMESTAMP`]
  CheckOutTarihi datetime
  ToplamTutar decimal(10,2) [note: "SP ile hesaplanıp buraya yazılacak"]
  Durum varchar(20) [not null, default: 'AKTIF', note: "'AKTIF', 'KAPANDI'"]
}

Table Odeme {
  OdemeID int [pk, increment]
  KonaklamaID int [ref: > Konaklama.KonaklamaID]
  OdemeYontemi varchar(50) [not null, note: "'NAKIT', 'KREDI_KARTI'"]
  OdenenTutar decimal(10,2) [not null]
  OdemeTarihi datetime [default: `CURRENT_TIMESTAMP`]
  Durum varchar(20) [not null, default: 'BASARILI']
}

// ==========================================
// 4. HİZMET VE OPERASYON
// ==========================================
Table EkHizmet {
  EkHizmetID int [pk, increment]
  HizmetAdi varchar(100) [not null]
  BirimFiyati decimal(10,2) [not null]
}

Table KonaklamaHizmeti {
  KonaklamaHizmetiID int [pk, increment]
  KonaklamaID int [ref: > Konaklama.KonaklamaID]
  EkHizmetID int [ref: > EkHizmet.EkHizmetID]
  Adet int [not null, default: 1]
  ToplamTutar decimal(10,2) [not null]
  AlinmaTarihi datetime [default: `CURRENT_TIMESTAMP`]
}

Table TemizlikKaydi {
  TemizlikID int [pk, increment]
  OdaID int [ref: > Oda.OdaID]
  PersonelID int [ref: > Personel.PersonelID]
  TemizlikTarihi datetime [default: `CURRENT_TIMESTAMP`]
  Aciklama text
}

// ==========================================
// 5. SİSTEM LOGLARI (Trigger'lar burayı besleyecek)
// ==========================================
Table IslemLog {
  LogID int [pk, increment]
  KullaniciID int [ref: > Kullanici.KullaniciID]
  IslemTipi varchar(50) [not null, note: "'REZERVASYON_EKLENDI', 'IPTAL_EDILDI', 'FIYAT_DEGISTI'"]
  TabloAdi varchar(50) [not null]
  KayitID int [not null]
  EskiDeger text
  YeniDeger text
  IslemTarihi datetime [default: `CURRENT_TIMESTAMP`]
}