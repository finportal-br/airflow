FROM apache/airflow:2.9.0

USER root
RUN pip install --upgrade pip && pip install pandas
USER airflow

COPY ./dags /opt/airflow/dags

ENTRYPOINT ["/entrypoint"]
CMD ["webserver"]