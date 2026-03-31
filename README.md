### Produzione e Stage
L'ambiente di produzione è rilasciato su un server VPS Aruba Ubuntu 24.04 LTS chiamato tanjiro con IP **31.14.138.171**.

È raggiungibile tramite apirone.it e stage.apirone.it

Per avviare il progetto è stato necessario installare:
- postgresql-16
- postgresql-common-dev
- nginx
- commandbox
- openjdk-11-jdk
- certbot (per l'ottenimento del certificato HTTPS)
- python3-certbot-nginx (per l'ottenimento del certificato HTTPS)

Una volta installato queste dependency è stato scaricato dal repository GitHub:
git@github.com:sangio90/apirone-app (riferimento al progetto https://github.com/sangio90/apirone-app)
nei branch "master" e "dev", master per la produzione (apirone.it) e "dev" per stage (stage.apirone.it)

I progetti sono installati in /var/www/vhosts/apirone_it/html e /var/www/vhosts/apirone_it_stage/html.

Ciascuno ha bisogno della sua repository di file e le due repository sono presenti in /var/www/vhosts/apirone_it/repository e /var/www/vhosts/apirone_it_stage/repository.

Una volta predisposti i file è stato necessario copiare i file .env.dist e server.json.dist in .env e server.json e modificare i file con le credenziali del database e i dati di ciascuna istanza di progetto.

I comandi di avvio dei due progetti (da lanciare nella cartella "html" di ciascuno dei due progetti) sono:

```bash
box server start --port=7120 --host=0.0.0.0 --configFile=server.json --nobrowser
```

Dove la porta 7120 è per la produzione e la 7121 è per stage.


#### Riavvio automatico
In `/usr/local/bin/apirone-start.sh` e `/usr/local/bin/apirone-stage-start.sh` sono configurati due script di avvio automatico di box.
Questi script partono perchè in `/etc/systemd/system/apirone.service` e `/etc/systemd/system/apirone-stage.service` sono stati definiti due servizi da avviare al riavvio del server sotto l'utenza guido.
Questi servizi lanciano gli script apirone-start e apirone-stage-start che avviano i comandi box nelle rispettive directory.

Nginx è configurato per fare da proxy su apirone.it e stage.apirone.it e reindirizzare le richieste alle rispettive porte **7120** e **7121**.

È possibile verificare lo stato dei server con il comando:

```bash
box
server list
server info
```

È possibile fermare un server con il comando:

```bash
box
server stop <server_name>
```

È possibile eliminare un server con il comando:

```bash
box
server stop <server_name>
server forget <server_name>
```

Poi, verificare che sia effettivamente fermo con:

```bash
sudo lsof -i:7120
```

Dove 7120 è la porta del server che si vuole fermare.

Per riavviare i servizi si può lanciare

```bash
sudo systemctl stop apirone
sudo systemctl start apirone

sudo systemctl stop apirone-stage
sudo systemctl start apirone-stage
```