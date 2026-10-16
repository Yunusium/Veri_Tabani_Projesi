-- SQL Server: Otel rezervasyon bilgilerini saklayan tablo
CREATE TABLE Rezervasyon (
    RezervasyonID INT IDENTITY(1,1) PRIMARY KEY,
    MisafirAdiSoyadi NVARCHAR(100) NOT NULL,
    Telefon VARCHAR(20) NOT NULL,
    Eposta NVARCHAR(254) NULL,
    OdaNo VARCHAR(20) NOT NULL,
    GirisTarihi DATE NOT NULL,
    CikisTarihi DATE NOT NULL,
    KisiSayisi SMALLINT NOT NULL,
    ToplamUcret DECIMAL(10, 2) NOT NULL,
    RezervasyonTarihi DATETIME2 NOT NULL
        CONSTRAINT DF_Rezervasyon_RezervasyonTarihi DEFAULT SYSDATETIME(),
    Durum NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Rezervasyon_Durum DEFAULT N'Beklemede',

    CONSTRAINT CK_Rezervasyon_Tarih
        CHECK (CikisTarihi > GirisTarihi),
    CONSTRAINT CK_Rezervasyon_KisiSayisi
        CHECK (KisiSayisi > 0),
    CONSTRAINT CK_Rezervasyon_ToplamUcret
        CHECK (ToplamUcret >= 0),
    CONSTRAINT CK_Rezervasyon_Durum
        CHECK (Durum IN (N'Beklemede', N'Onaylandi', N'Iptal', N'Tamamlandi'))
);