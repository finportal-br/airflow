FROM apache/airflow:2.9.0

# Use ambiente virtual próprio do airflow user
USER airflow

# Instala pacotes como o próprio usuário (conforme recomendação oficial)
RUN pip install --user --upgrade pip && pip install --user pandas

# Copia suas DAGs
COPY ./dags /opt/airflow/dags

# Comando padrão
ENTRYPOINT ["/entrypoint"]
CMD ["webserver"]
