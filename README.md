# 🛒 Q3 Profitability Analysis E-Commerce SAMALARIS (2026)

## 📌 Executive Summary
Proyek ini bertujuan untuk mendiagnosis penurunan performa penjualan dan lonjakan drastis *return rate* (tingkat pengembalian barang) pada toko e-commerce **SAMALARIS** selama periode Q3 2026. Menggunakan pendekatan **Exploratory Data Analysis (EDA)** dan **Diagnostic Analytics**, proyek ini mengidentifikasi akar masalah operasional serta memberikan rekomendasi bisnis untuk menurunkan *return rate* dan meningkatkan *customer satisfaction*.

---

## 🎯 Business Problem & Objectives
Pada Q3 2026, SAMALARIS mengalami penurunan pendapatan efisien akibat lonjakan angka pengembalian barang (*return rate*) yang mencapai angka kritikal (**55,75%** dari total pesanan). 

**Tujuan Utama Analisis:**
- Mendiagnosis tren performa penjualan dan retur secara kuartalan.
- Mengidentifikasi kategori produk, SKU, dan wilayah dengan angka retur paling tinggi.
- Menganalisis faktor operasional.
- Merumuskan rekomendasi strategi untuk menurunkan *return rate* dan meningkatkan *customer satisfaction*.

---

## 📊 Dataset Overview
- **Sumber Data:** Data Transaksi Internal SAMALARIS (Q1 - Q3 2026)
- **Cakupan Data:**
  - **Total Orders (Q3):** 1.487 Transaksi
  - **Total Returns (Q3):** 829 Transaksi (*Return Rate*: 55,75%)
  - **Kategori Produk Utama:** Fashion, Peralatan Rumah Tangga, Olahraga, Kecantikan, Elektronik.
  - **Metode Pembayaran:** COD, Transfer Bank, E-Wallet, Credit Card.

---

## 🔍 Key Findings & Root Cause Analysis

### 1. Lonjakan Anomali Retur Berdasarkan Kategori
* Kategori **Fashion** menjadi penyumbang retur terbesar dengan persentase retur mencapai **73,88%**.
* **Akar Masalah Utama Retur (Pareto Distribution):**
  1. *Damaged in Transit* (30,76%)
  2. *Product Quality / Mismatch* (28,83%)
  3. *Wrong Size / Fit* (23,88%)
  4. *Delayed Delivery* (16,53%)

### 2. Evaluasi Performa Kurir & Wilayah
* Terjadi masalah serius pada durasi dan keamanan pengiriman di wilayah luar Jawa (khususnya Medan & Makassar).
* Kurir mitra tertentu menunjukkan tingkat kerusakan barang (*Damaged in Transit*) jauh di atas rata-rata operasional aman.

### 3. Kerentanan Metode Pembayaran COD
* Transaksi dengan metode pembayaran **COD (Cash on Delivery)** memiliki tingkat kerentanan retur paling tinggi yaitu **62,89%**.
* *Insight:* Kombinasi antara kategori *Fashion* (masalah ukuran/fit) dan metode pembayaran COD meningkatkan kecenderungan pembeli untuk menolak/mengembalikan barang saat kurir sampai.

---

## 💡 Actionable Business Recommendations

1. **Perbaikan Kontrol Kualitas Produk & Panduan Ukuran (Kategori Fashion):**
   - Perbarui *size chart* dengan detail pengukuran yang presisi (panjang, lebar, lingkar dada) dan sertakan panduan visual/foto *model height & weight*.
   - Tingkatkan *Quality Control* (QC) sebelum barang dikemas untuk memastikan deskripsi fisik sesuai dengan produk asli.
   - Berikan layanan pelanggan untuk konsultasi terkait ukuran sebelum membeli. Dan jadikan hal tersebut syarat pengembalian, Jika pelanggan tidak melakukan            konsultasi sebelumnya maka permintaan untuk retur bisa ditolak.

2. **Evaluasi Mitra Logistik & Standar Packaging:**
   - Terapkan standar pengemasan ekstra (*extra bubble wrap* / *hardbox*) khusus untuk pengiriman luar pulau untuk menekan angka *Damaged in Transit* (30,76%).
   - Berikan peringatan/KPI tegas kepada kurir mitra dengan tingkat kerusakan barang tertinggi di wilayah Medan dan Makassar.
   - Atur pilihan kurir saat pelanggan ingin checkout untuk wilayah pengiriman ke Medan melalui SiCepat saja karena resiko rasio suksesnya tertinggi di wilayah         Medan. Kemudian untuk pengiriman wilayah Makassar dialokasikan ke J&T dan untuk wilayah Pulau Jawa gunakan SiCepat dan J&T.

3. **Optimasi Kebijakan Pembayaran COD:**
   - Terapkan syarat & ketentuan khusus untuk fitur COD pada kategori *Fashion* (misal: konfirmasi sebelum pengiriman).
   - Berikan insentif kecil (seperti potongan ongkir atau *cashback*) untuk mendorong pembeli beralih dari COD ke metode pembayaran non-tunai (*digital payment*).

---

## 🛠️ Tools & Skills Used
- **Analytical Method:** Exploratory Data Analysis (EDA), Diagnostic Analytics
- **Tools:** Python / SQL / Power BI 

---
## 📸 Power BI Dashboard
<img width="1364" height="763" alt="Screenshot 2026-10-30 214234" src="https://github.com/user-attachments/assets/531ad2b9-5ff9-4c60-bbc2-5e8e89bba065" />

