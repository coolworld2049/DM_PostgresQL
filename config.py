from envparse import env

env.read_envfile('.env')

PG_RUN_ON_DOCKER = True

PG_CONFIG = {
    "host": 'postgres' if PG_RUN_ON_DOCKER else env.str("PG_HOST", default='127.0.0.1'),
    "port": env.int("PG_PORT", default=5432),
    "database": env.str("PG_DATABASE", default='postgres'),
    "user": env.str("PG_USER", default='postgres'),
    "password": env.str("PG_PASSWORD", default=None),
}

PG_DSN = f"postgresql://{PG_CONFIG['user']}:{PG_CONFIG['password']}" \
         f"@{PG_CONFIG['host']}:{PG_CONFIG['port']}/{PG_CONFIG['database']}"

MONGO_CONFIG = {
    "host": env.str("MONGO_HOST", default='127.0.0.1'),
    "port": env.int("MONGO_PORT", default=6379),
    "user": env.str("MONGO_INITDB_ROOT_USERNAME", default='root'),
    "password": env.str("MONGO_INITDB_ROOT_PASSWORD", default='root'),
}

MONGO_URI = f"mongodb://{MONGO_CONFIG['user']}:{MONGO_CONFIG['password']}" \
         f"@{MONGO_CONFIG['host']}:{MONGO_CONFIG['port']}"
