"""全国の人流オープンデータ（国土交通省）のデータパイプライン。

1. people_flow: G空間情報センターの配布物を取り、都道府県ごとの Parquet とマスタの CSV にする
2. dbt: dbt ビルド
"""

import logging

from dbt.cli.main import dbtRunner

from pipelines.people_flow import download_people_flow

# dbt を読み込むとルートロガーが先に設定されるので、force で上書きする
logging.basicConfig(level=logging.INFO, format="%(message)s", force=True)
logger = logging.getLogger("pipelines")


def dbt_build():
    dbt = dbtRunner()
    for command in (["deps"], ["build"], ["docs", "generate"]):
        result = dbt.invoke(command)
        if not result.success:
            raise SystemExit(f"dbt {' '.join(command)} failed")


def main():
    logger.info("1/2: people_flow (全国の人流オープンデータ)")
    download_people_flow()

    logger.info("2/2: dbt build")
    dbt_build()


if __name__ == "__main__":
    main()
