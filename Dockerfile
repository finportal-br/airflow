FROM apache/airflow:2.9.0

USER airflow

# Instalação correta de pacotes no virtualenv ativo
ENV AIRFLOW_HOME=/opt/airflow
RUN pip install --no-cache-dir pandas

COPY ./dags /opt/airflow/dags

ENTRYPOINT ["/entrypoint"]
CMD ["webserver"]
