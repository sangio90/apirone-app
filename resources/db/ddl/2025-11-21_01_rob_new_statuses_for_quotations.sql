UPDATE statuses
SET
    orderby = orderby * 10;

UPDATE statuses
SET
    status_id = 'PEN',
    status = 'In attesa di conferma'
WHERE
    status_id = 'PRO';

UPDATE statuses
SET
    status = 'Approvato',
    orderby = 35
WHERE
    status_id = 'APR';

INSERT INTO
    statuses (status_id, status, entities, orderby, color_id)
VALUES
    (
        'CCN',
        'Confermato da cliente',
        '["QUOTATION"]',
        37,
        'C30'
    );

DELETE FROM statuses
WHERE
    status_id IN ('NEW', 'END');

UPDATE statuses
SET
    status = 'In approvazione'
WHERE
    status_id = 'PEN';

/*
status_id |        status         | orderby
----------+-----------------------+--------
LAV       | In Lavorazione        |      10
PEN       | In approvazione       |      20
APR       | Approvato             |      35
CCN       | Confermato da cliente |      37
CON       | Convertito in Ordine  |      40
PER       | Perso                 |      50
EST       | Estinto               |      60
*/