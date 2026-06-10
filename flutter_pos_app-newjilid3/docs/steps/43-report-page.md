# 43 — ReportPage (Summary, Trend Chart, Product Sales, Export PDF)

## Goal

Halaman laporan: pilih date range, render 4 metric cards (transaksi, revenue, avg order, items terjual), trend chart 7-hari, top products, tombol export PDF.

## Prerequisite

- Step 42 selesai.
- `ReportRemoteDatasource` (GET /api/report/summary, GET /api/report/product-sales).

## Konsep yang diajarkan

- **3 bloc terpisah** untuk reporting: SummaryBloc, ProductSalesBloc, CloseCashierBloc (legacy).
- **`pdf` package** untuk generate PDF + `open_filex` untuk buka.
- **`fl_chart`** dipakai via `AppTrendChart` (step 09).

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `AppTrendChart` siap (step 09). Package `pdf`, `open_filex`, `path_provider`.

Generate 7 file.

═══════════════════════════════════════════════
FILE 1: lib/data/models/response/summary_response_model.dart
═══════════════════════════════════════════════
`SummaryResponseModel` { bool success; SummaryData data; }. `SummaryData`:
- `totalTransactions: int, totalRevenue: int, totalItems: int, avgOrderValue: int`.
- `dailyTotals: List<DailyTotal>` (date string + amount).

═══════════════════════════════════════════════
FILE 2: lib/data/models/response/product_sales_report.dart
═══════════════════════════════════════════════
`ProductSalesReport` { bool success; List<ProductSalesItem> data; }. Item:
- `productId, name, quantitySold, totalRevenue, category`.

═══════════════════════════════════════════════
FILE 3: lib/data/datasources/report_remote_datasource.dart
═══════════════════════════════════════════════
```dart
class ReportRemoteDatasource {
  Future<Either<String, SummaryResponseModel>> getSummary({
    required DateTime from, required DateTime to,
  }) async {
    final auth = await AuthLocalDatasource().getAuthData();
    final res = await http.get(
      Uri.parse('${Variables.baseUrl}/api/report/summary?from=${from.toIso8601String()}&to=${to.toIso8601String()}'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );
    return res.statusCode == 200
      ? right(SummaryResponseModel.fromJson(res.body))
      : left(res.body);
  }

  Future<Either<String, ProductSalesReport>> getProductSales({
    required DateTime from, required DateTime to,
  }) async { /* similar GET /api/report/product-sales */ }

  Future<Either<String, dynamic>> getCloseCashier({...}) async { /* GET /api/report/close-cashier */ }
}
```

═══════════════════════════════════════════════
FILE 4-5: SummaryBloc + ProductSalesBloc
═══════════════════════════════════════════════
4-state Freezed (initial/loading/success/error). Event: `fetch(from, to)`. Handler call respective datasource method.

═══════════════════════════════════════════════
FILE 6: lib/presentation/setting/pages/report/report_page.dart
═══════════════════════════════════════════════
StatefulWidget. State: `_from: DateTime`, `_to: DateTime`, `_rangeKey: String = 'today'`.

initState: `_setRange('today')` → fire SummaryBloc.fetch + ProductSalesBloc.fetch.

`_setRange(key)`:
- today: from=midnight today, to=now.
- week: from=monday this week, to=now.
- month: from=1st this month, to=now.
- custom: showDateRangePicker.

Build:
- Scaffold(bg surface, appBar: AppAppBar('Laporan', trailing: [AppIconButton(file_download_outlined, onPressed: _exportPdf)])).
- body ListView padding 16:
  1. **Date range chips**: Wrap horizontal AppChip(Hari ini/Minggu/Bulan/Custom).
  2. SpaceHeight 16.
  3. **4 metric cards** (2×2 grid):
     - For each: AppCard padding 14: Icon + Text label bodyS onSurfaceVar + Text value priceL.
     - "Transaksi" (count), "Revenue" (rupiah), "Item Terjual" (count), "Avg Order" (rupiah).
  4. SpaceHeight 16.
  5. **AppSectionLabel('Trend 7 Hari')**.
  6. AppCard: `AppTrendChart(data: dailyTotals.map(amount), labels: dailyTotals.map(dayShort))`.
  7. SpaceHeight 16.
  8. **AppSectionLabel('Top Produk')**.
  9. AppListGroup of top 10 product sales: Row: ProductImg 40 + Column [name, '${qty} terjual'] + Text revenue.currencyFormatRp.
  10. SpaceHeight 16.
  11. AppButton.outline('Export PDF', leadingIcon: picture_as_pdf, onPressed: _exportPdf).

`_exportPdf()`:
- Build PDF dengan `pw.Document()`:
  - Header: Title "Laporan ${range}", date range.
  - 4 metric grid.
  - Table top product (name, qty, revenue).
- Save to `getApplicationDocumentsDirectory()/report-${ts}.pdf`.
- `OpenFilex.open(path)` to view.

═══════════════════════════════════════════════
WIRING
═══════════════════════════════════════════════
- main.dart: BlocProvider Summary, ProductSales, CloseCashier (optional legacy).
- SettingPage tile "Laporan" → push ReportPage.
````

---

## Verifikasi

1. Setting → Laporan → tampil dengan default 'Hari ini'.
2. Tap chip 'Minggu' → re-fetch.
3. Tap 'Custom' → pick range → re-fetch.
4. Tap Export PDF → file ter-generate → buka di PDF viewer.

## Talking points

1. **Kenapa bloc terpisah summary vs product sales?**
   Beda endpoint, beda model, beda refresh rate. UI bisa show 1 loaded sebelum yang lain selesai.

2. **`pdf` package**:
   Generate PDF dari Dart code. Pakai `pw.Document`, `pw.Page`, `pw.Container`. Output bytes → save file.

3. **`AppTrendChart` minimal data**:
   Cuma 7 datapoint daily. Kalau ribuan, ganti ke `BarChart`.

4. **`getApplicationDocumentsDirectory()`** (path_provider):
   Lokasi internal app. Dihapus saat user uninstall. Untuk export permanen → `getExternalStorageDirectory()` + permission.

5. **Top 10 produk**:
   Sort by quantitySold desc, take 10. UI tampilkan; biar BE yang aggregate berat-nya.

## Commit suggestion

```bash
git add lib/data/models/response/summary_response_model.dart lib/data/models/response/product_sales_report.dart lib/data/datasources/report_remote_datasource.dart lib/presentation/setting/bloc/report/ lib/presentation/setting/pages/report/ lib/main.dart
git commit -m "Step 43: ReportPage with metrics, trend chart, top products, PDF export"
```

---

➡️ Lanjut ke [Step 44 — Connectivity + Auto-sync](./44-connectivity-auto-sync.md)
