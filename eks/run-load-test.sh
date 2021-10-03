export LOAD_TEST_REPORT_DATA=report.json
artillery run -o $LOAD_TEST_REPORT_DATA artillery-test-conf.yaml
artillery report $LOAD_TEST_REPORT_DATA
