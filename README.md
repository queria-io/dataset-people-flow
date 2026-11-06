# 全国の人流オープンデータ（国土交通省）

国土交通省の「全国の人流オープンデータ」を、SQL で検索・集計できるテーブルにしたデータセットです。2019 年 1 月〜2021 年 12 月の月ごとの滞在人口を、全国の 1km メッシュ別と、市区町村別に滞在者の居住地で分けたもので収録しています。平日・休日と、昼・深夜・終日で分かれています。

## 出典と利用条件

[全国の人流オープンデータ（1kmメッシュ、市区町村単位発地別）](https://www.geospatial.jp/ckan/dataset/mlit-1km-fromto)（G空間情報センター）の CSV を加工しています。

| 原典 | テーブル |
| --- | --- |
| 1kmメッシュ別の滞在人口データ（`monthly_mdp_mesh1km`） | `stay.mesh_population` |
| 市区町村単位発地別の滞在人口データ（`monthly_fromto_city`） | `stay.city_population_by_origin` |
| 1kmメッシュ属性（`attribute`、2020 年版） | `stay.mesh` |
| 都道府県・市区町村マスタ（`prefcode_citycode_master`）と地方区分マスタ（`regioncode_master`） | `stay.city` |

- [全国の人流オープンデータ利用規約](https://www.geospatial.jp/ckan/dataset/mlit-1km-fromto/resource/5a3705d7-b321-4f33-b0d9-0c4c379e96c3)（政府標準利用規約 2.0 準拠、CC BY 4.0 互換）に従います。商用利用もできます
- 使うときは「出典：『全国の人流オープンデータ』（国土交通省）（https://www.geospatial.jp/ckan/dataset/mlit-1km-fromto）を加工して作成」のように出典と加工したことを書いてください。Queria の値をさらに集計・加工したときも同じです

## テーブル

| テーブル | 内容 |
| --- | --- |
| `stay.mesh_population` | 1 行が 1 メッシュ・1 か月・平休日・時間帯の滞在人口。3,808 万行 |
| `stay.city_population_by_origin` | 1 行が 1 市区町村・1 か月・平休日・時間帯・居住地区分の滞在人口。234 万行 |
| `stay.mesh` | 1 行が 1 つの 1km メッシュ。形・中心と、属する都道府県・市区町村。38 万行 |
| `stay.city` | 1 行が 1 市区町村。名前と地方区分 |

## 使い方

駅の周りの休日の昼の人出を、2019〜2021 年の 4 月で比べる（駅は国土数値情報の `nlftp.railway.station`）:

```sql
WITH station_mesh AS (
    SELECT DISTINCT s.station_name, m.mesh_code
    FROM nlftp.railway.station AS s
    JOIN people_flow.stay.mesh AS m ON ST_Contains(m.geometry, s.geometry)
    WHERE s.station_name IN ('新宿', '渋谷') AND m.prefecture_code = '13'
)
SELECT station_name, date, sum(population) AS population
FROM people_flow.stay.mesh_population AS p
JOIN station_mesh USING (mesh_code)
WHERE p.day_type = '休日' AND p.time_of_day = '昼'
  AND p.date IN ('2019-04-01', '2020-04-01', '2021-04-01')
GROUP BY ALL
ORDER BY station_name, date;
```

駅の代表点は路線ごとにあるので、1 つの駅が複数のメッシュにかかることがあります。

平日の昼の滞在人口を、国勢調査の夜間人口（`e_stat.census.population_mesh_1km`）と比べる:

```sql
SELECT p.mesh_code, p.population AS weekday_daytime, c.value AS census_population,
       round(p.population / c.value, 1) AS ratio
FROM people_flow.stay.mesh_population AS p
JOIN e_stat.census.population_mesh_1km AS c ON c.mesh_code = p.mesh_code AND c.cat01 = '0010'
WHERE p.date = '2019-10-01' AND p.day_type = '平日' AND p.time_of_day = '昼'
  AND p.prefecture_code = '13' AND c.value >= 100
ORDER BY ratio DESC;
```

市区町村に県外から来た人の推移:

```sql
SELECT date, origin, population
FROM people_flow.stay.city_population_by_origin
WHERE lg_code = '472077'  -- 沖縄県石垣市
  AND day_type = '休日' AND time_of_day = '昼'
  AND origin IN ('同一地方', '他の地方')
ORDER BY date, origin;
```

`mesh_code` は e-Stat などのメッシュ統計と同じ 3 次メッシュコード（8 桁）、`city_code` は 5 桁の市区町村コード、`lg_code` は検査数字を付けた 6 桁の全国地方公共団体コードです。地図にするときは `mesh_population` の `lng`・`lat`（メッシュの中心）か、`mesh` の `geometry` を使います。

## 滞在人口の注意

- 株式会社 Agoop がスマートフォンのアプリから集めた位置情報を、日本の総人口に拡大推計し、滞在時間で按分した換算人口です。詳しい作り方は原典の[定義書](https://www.geospatial.jp/ckan/dataset/mlit-1km-fromto/resource/e2083495-8095-4119-a865-e5c22e6a7eee)にあります
- 値はその月の 1 日あたりの平均です。月をまたいで合計すると意味のない数になります。期間で比べるときは月ごとの値か、その平均を使います
- 時間帯は、昼が 11〜14 時台、深夜が 1〜4 時台、終日が 0〜23 時台の平均です。休日は土曜・日曜・祝日です
- 全日・終日の行は、平日と休日、昼と深夜の合計ではありません（それぞれの平均です）。`day_type` と `time_of_day` は 1 つずつに絞って使います
- 10 人未満の値は原典が出力していないため、行がありません。人の少ないメッシュ・市区町村・居住地区分は欠けます
- メッシュの合計は、滞在した人を場所ごとに数えたものです。終日の値を全国で合計すると、ほぼ日本の総人口になります（2020 年 1 月の全日・終日で 1 億 2,688 万人）
- 居住地区分の「同一都道府県」は同じ都道府県のほかの市区町村、「同一地方」は同じ地方のほかの都道府県、「他の地方」はそれ以外です。地方は `stay.city` の `region`（北海道・東北・関東・北陸・中部・近畿・中国・四国・九州・沖縄）です
- 政令指定都市は区の単位で、市の合計の行はありません

## コードの注意

- 福岡県那珂川市は、2019 年のデータでは旧那珂川町のコード（40305）です。2020 年から 40231 です。続けて見るときは両方のコードで絞ります
- `city_population_by_origin` の 2019 年には、北方領土の色丹村・泊村・蘂取村（01695・01696・01699）の行が少しあります。`stay.city` には入っていません
- `stay.mesh` の都道府県・市区町村は 2020 年版の 1km メッシュ属性によります。2019 年版とは、那珂川市など 70 メッシュの市区町村コードが違います。各年の値は `mesh_population` の `city_code` にあります
- メッシュの形と中心はメッシュコードから計算しています。原典の座標は単精度に丸められているため、使っていません（差は 1e-5 度以内です）

## ビルド

```bash
git submodule update --init
uv sync
scripts/build.sh   # fdl checkout → python main.py → fdl commit
```

配布物は 106 個の zip で、全部で約 190MB です。取得した zip は `data/raw/` に置いて使い回します。原典は 2021 年 12 月分で公開を終えているため、定期実行はしません。main への push と手動の実行（workflow_dispatch）で Sync が実行されます。PR のビルド確認（`.github/workflows/build.yml`）は東京都と沖縄県だけ取得します（`PEOPLE_FLOW_PREFECTURES=13,47`）。
