import time
import pandas as pd
from sqlalchemy import create_engine
from fake_web_events import Simulation

# Configuração do Postgres (ajuste para o seu ambiente)
USER = "postgres"
PASSWORD = "Mds20251"
HOST = "datahandson-engdados-dev-postgres.cnai0csqspw4.us-east-2.rds.amazonaws.com"
PORT = "5432"
DB = "ecommerce"

engine = create_engine(f"postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB}")

# Simulador
simulation = Simulation(user_pool_size=100, sessions_per_day=100000)


while True:
    print("Gerando eventos...")
    events = simulation.run(duration_seconds=1)
    df = pd.DataFrame(events)

    if not df.empty:
        df.to_sql("web_events", engine, if_exists="append", index=False)
        print(f"{len(df)} eventos salvos no Postgres!")

    time.sleep(60)
