version: "3.9"
services:
  koha:
    image: teogramm/koha:24.11
    ports:
      - 8080:8080
      - 8081:8081
    networks:
      - koha
    cap_add:
      - DAC_READ_SEARCH
      - SYS_NICE
    environment:
      MYSQL_SERVER: db
      MYSQL_USER: koha_teolib
      MYSQL_PASSWORD: example
      DB_NAME: koha_teolib
      MEMCACHED_SERVERS: memcached:11211
      MB_HOST: rabbitmq
    depends_on:
      db:
        condition: service_healthy   # <--- CAMBIO IMPORTANTE: Espera a que el healthcheck pase
      rabbitmq:
        condition: service_started
      memcached:
        condition: service_started

  rabbitmq:
      image: docker.io/rabbitmq:3
      volumes:
        - ./rabbitmq_plugins:/etc/rabbitmq/enabled_plugins
      networks:
        - koha

  db:
    image: docker.io/mariadb:11
    volumes:
      - mariadb-koha:/var/lib/mysql
    environment:
      MARIADB_ROOT_PASSWORD: example
      MARIADB_DATABASE: koha_teolib
      MARIADB_USER: koha_teolib
      MARIADB_PASSWORD: example
    networks:
      - koha
    # AÑADIMOS ESTO: El chequeo de salud
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  memcached:
    image: docker.io/memcached
    networks:
      - koha

volumes:
    mariadb-koha:

networks:
    koha:
