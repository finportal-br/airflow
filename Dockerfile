FROM apache/airflow:2.9.0

USER airflow

ENV AIRFLOW_HOME=/opt/airflow
RUN pip install --no-cache-dir pandas

COPY ./dags /opt/airflow/dags

# Entrypoint padrão e comando explícito para iniciar o webserver
ENTRYPOINT ["/entrypoint"]
CMD ["airflow", "webserver"]
