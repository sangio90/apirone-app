-- Migrazione dati placche: seed frame_blocks dai file grid_*.json.cfm
-- e conversione delle posizioni frutti da guid a interi progressivi.
--
-- Generato automaticamente analizzando i file in config/data/plates/.
-- Margini (scala 1mm = 1px, ricavati dalle dimensioni px legacy):
-- lungo l asse della placca il margine è riferito al blocco precedente
-- (LEFT con placca orizzontale, TOP con placca verticale; primo blocco:
-- dal bordo); l altro margine è riferito al bordo della placca.
-- Rifinire i margini reali dalla pagina di gestione placche (/manager/frames).
--
-- ESEGUIRE IN TRANSAZIONE su una copia/backup verificata del DB.
--
-- Note generate:
-- 501: celle VER su riga HOR -> blocchi singoli fissi VER (verificare manualmente)
-- 507/VER: solo 14 slot su 16 del layout base

BEGIN;

-- ====== 1. Seed frame_blocks (solo per blocchi non ancora presenti) ======

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 2, 0, 0, 'HOR'
FROM frames f
WHERE f.code = '1X2'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 1, 2, 105, 0, 'HOR'
FROM frames f
WHERE f.code = '1X2'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 1 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 4, 0, 0, 'HOR'
FROM frames f
WHERE f.code = '2X2'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 1, 4, 0, 52, 'HOR'
FROM frames f
WHERE f.code = '2X2'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 1 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 4, 0, 0, 'HOR'
FROM frames f
WHERE f.code = '2X3'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 1, 4, 0, 104, 'HOR'
FROM frames f
WHERE f.code = '2X3'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 1 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 2, 4, 0, 104, 'HOR'
FROM frames f
WHERE f.code = '2X3'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 2 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 4, 0, 0, 'HOR'
FROM frames f
WHERE f.code = '3X2'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 1, 4, 0, 52, 'HOR'
FROM frames f
WHERE f.code = '3X2'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 1 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 2, 4, 0, 52, 'HOR'
FROM frames f
WHERE f.code = '3X2'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 2 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 8, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '4TS'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 1, 0, 0, 'VER'
FROM frames f
WHERE f.code = '501'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 1, 1, 0, 0, 'VER'
FROM frames f
WHERE f.code = '501'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 1 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 4, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '502'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 6, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '503'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 8, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '504'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 10, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '505'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 12, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '506'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 16, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '507'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 16, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '508'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

INSERT INTO frame_blocks (frame_id, "order", slot_count, margin_top_mm, margin_left_mm, orientation_mode)
SELECT f.frame_id, 0, 18, 0, 0, 'HAV'
FROM frames f
WHERE f.code = '509'
  AND NOT EXISTS ( SELECT 1 FROM frame_blocks fb WHERE fb.frame_id = f.frame_id AND fb."order" = 0 );

-- ====== 2. Mappatura guid -> slot intero ======

CREATE TABLE IF NOT EXISTS tmp_slot_guid_map (
    frame_code VARCHAR(5) NOT NULL,
    guid VARCHAR(50) NOT NULL,
    slot_int INTEGER NOT NULL,
    PRIMARY KEY (frame_code, guid)
);

INSERT INTO tmp_slot_guid_map (frame_code, guid, slot_int) VALUES
('1X2', '09c1f4b2-3bfa-4493-8c11-34cf0b279147', 1),
('1X2', 'ff976d33-a65f-40f7-8cf1-a34866e9b2cb', 2),
('1X2', '9c6660c8-7fd0-4342-8c22-a42034a0dabf', 3),
('1X2', '52e0337d-aeff-4776-9b3e-121faad55dc7', 4),
('2X2', 'a1b2c3d4-e5f6-47h8-89j0-k1l2m3n4o5p6', 1),
('2X2', 'q7r8s9t0-u1v2-43x4-95z6-a7b8c9d0e1f2', 2),
('2X2', 'g3h4i5j6-k7l8-49n0-81p2-q3r4s5t6u7v8', 3),
('2X2', 'w9x0y1z2-a3b4-45d6-87f8-g9h0i1j2k3l4', 4),
('2X2', 'c1d2e3f4-g5h6-47j8-89l0-m1n2o3p4q5r6', 5),
('2X2', 's7t8u9v0-w1x2-43z4-95b6-c7d8e9f0g1h2', 6),
('2X2', 'i3j4k5l6-m7n8-49p0-81r2-s3t4u5v6w7x8', 7),
('2X2', 'y9z0a1b2-c3d4-45f6-87h8-i9j0k1l2m3n4', 8),
('2X2', 'o5p6q7r8-s9t0-41v2-83x4-y5z6a7b8c9d0', 1),
('2X2', 'e1f2g3h4-i5j6-47l8-89n0-o1p2q3r4s5t6', 2),
('2X2', 'u7v8w9x0-y1z2-43b4-95d6-e7f8g9h0i1j2', 3),
('2X2', 'k3l4m5n6-o7p8-49r0-81t2-u3v4w5x6y7z8', 4),
('2X2', 'm3n4o5p6-q7r8-49t0-81v2-w3x4y5z6a7b8', 5),
('2X2', 'c9d0e1f2-g3h4-45j6-87l8-m9n0o1p2q3r4', 6),
('2X2', 's5t6u7v8-w9x0-41z2-83b4-c5d6e7f8g9h0', 7),
('2X2', 'i1j2k3l4-m5n6-47p8-89r0-s1t2u3v4w5x6', 8),
('2X3', 'a1b2c3d4-e5f6-47h8-89j0-k1l2m3n4o5p6', 1),
('2X3', 'q7r8s9t0-u1v2-43x4-95z6-a7b8c9d0e1f2', 2),
('2X3', 'g3h4i5j6-k7l8-49n0-81p2-q3r4s5t6u7v8', 3),
('2X3', 'w9x0y1z2-a3b4-45d6-87f8-g9h0i1j2k3l4', 4),
('2X3', 'c1d2e3f4-g5h6-47j8-89l0-m1n2o3p4q5r6', 5),
('2X3', 's7t8u9v0-w1x2-43z4-95b6-c7d8e9f0g1h2', 6),
('2X3', 'i3j4k5l6-m7n8-49p0-81r2-s3t4u5v6w7x8', 7),
('2X3', 'y9z0a1b2-c3d4-45f6-87h8-i9j0k1l2m3n4', 8),
('2X3', 'd2e3f4g5-h6i7-48k9-90m1-n2o3p4q5r6s7', 9),
('2X3', 't8u9v0w1-x2y3-44a5-96c7-d8e9f0g1h2i3', 10),
('2X3', 'j4k5l6m7-n8o9-50q1-82s3-t4u5v6w7x8y9', 11),
('2X3', 'z0a1b2c3-d4e5-46g7-88i9-j0k1l2m3n4o5', 12),
('2X3', 'o5p6q7r8-s9t0-41v2-83x4-y5z6a7b8c9d0', 1),
('2X3', 'e1f2g3h4-i5j6-47l8-89n0-o1p2q3r4s5t6', 2),
('2X3', 'u7v8w9x0-y1z2-43b4-95d6-e7f8g9h0i1j2', 3),
('2X3', 'k3l4m5n6-o7p8-49r0-81t2-u3v4w5x6y7z8', 4),
('2X3', 'p6q7r8s9-t0u1-42w3-84y5-z6a7b8c9d0e1', 5),
('2X3', 'f2g3h4i5-j6k7-48m9-90o1-p2q3r4s5t6u7', 6),
('2X3', 'v8w9x0y1-z2a3-44c5-96e7-f8g9h0i1j2k3', 7),
('2X3', 'l4m5n6o7-p8q9-50s1-82u3-v4w5x6y7z8a9', 8),
('2X3', 'm5n6o7p8-q9r0-51t2-83v4-w5x6y7z8a9b0', 9),
('2X3', 'f3g4h5i6-j7k8-49m0-91o2-p3q4r5s6t7u8', 10),
('2X3', 'v9w0x1y2-z3a4-45c6-97e8-f9g0h1i2j3k4', 11),
('2X3', 'l5m6n7o8-p9q0-51s2-83u4-v5w6x7y8z9a0', 12),
('3X2', 'e6485da9-f92c-45cd-8f24-490010dc7ac0', 1),
('3X2', '4b44e8e0-596f-42e8-88ae-f0698156189f', 2),
('3X2', '267b3a92-6d1f-4ceb-bf57-9e28020315de', 3),
('3X2', '8053b006-11b6-4f66-a735-1ca9898be2bc', 4),
('3X2', '70e45cdb-e20b-49ca-9a8b-5623272a8713', 5),
('3X2', '6908874d-d47d-4a71-808d-a88d8df48701', 6),
('3X2', '582e80ad-5374-47c7-8f21-3e124a0360df', 7),
('3X2', '33dc102b-ca40-459b-850a-7230563481dc', 8),
('3X2', '6a40dbc4-445b-44e2-b8de-a157ad7979ec', 9),
('3X2', '7d395174-f340-422d-90ae-bcfc62920e74', 10),
('3X2', '9325ad83-2e87-40d3-b1ab-cd0dbdd104c8', 11),
('3X2', '8e44fc04-9d83-4176-94ca-29e8a5c8775f', 12),
('3X2', 'dc6b0c5f-b06f-4396-88ac-a08f0716eb41', 1),
('3X2', '9efaaa5b-33d8-4cc4-b709-ee0416179982', 2),
('3X2', 'c72c1c45-8cd6-4f1c-a850-89fd265a520e', 3),
('3X2', 'f0c3c689-8232-4dd7-b763-8884ce7d5f65', 4),
('3X2', '733daf11-718a-4304-90dc-054d05777c53', 5),
('3X2', 'b74d974c-167e-422c-8e3b-4dda64c9a52e', 6),
('3X2', '33c7bbe8-367e-4092-b039-064ff70e857b', 7),
('3X2', '42e2582b-660b-4bd6-afbe-eaf2ad1f53e5', 8),
('3X2', '3d0530ac-d7d4-48d6-80d4-b91f7a265280', 9),
('3X2', '363336b2-7993-4a30-82dc-ad80dda2f816', 10),
('3X2', '53beae64-7f4a-4f36-9cb6-d5df73fe7a38', 11),
('3X2', '57e43281-6261-452a-94bc-273caa985d3a', 12),
('4TS', '84a9aabe-5586-4c54-b64d-55171f69e224', 1),
('4TS', '8389200e-c36c-447e-b8a3-45372560e341', 2),
('4TS', 'c5a3058c-2085-42dc-b040-63aac654b3e9', 3),
('4TS', '3008ab6e-dcbe-493c-8d5b-9fbc43bfb29e', 4),
('4TS', '5c7378c0-856b-4796-a431-d944685c69ee', 5),
('4TS', '09198524-593b-47c9-a3ac-5538c187a0dc', 6),
('4TS', '52b73421-e1f5-4fd6-ace5-7df7f46ea786', 7),
('4TS', 'a4cc3e74-02b3-4ade-b0eb-3265417cf396', 8),
('4TS', '564a2044-a22a-49c8-be45-94bbd56cf676', 1),
('4TS', '2abb8205-3c5f-4542-9998-8f78fd383dae', 2),
('4TS', '87549dc1-e43d-4ef7-b649-c9f8779ab61e', 3),
('4TS', '7ce0f1ae-6282-4882-9c85-92375ecab756', 4),
('4TS', '882bd3bc-3d21-4dca-9058-8e8af1eefbb7', 5),
('4TS', 'ed5b8718-6732-4295-a268-987840a3e398', 6),
('4TS', '63a13e79-d7fc-4080-a762-e881c33aa99d', 7),
('4TS', 'a9220a45-86f7-4cd7-b3c4-7a00f5c53bf6', 8),
('501', '9179e2c7-8c6f-48dc-8e0c-30af1298f15f', 1),
('501', '6a7d33c4-c93a-4d33-8675-2ae9a0d3e58a', 2),
('501', '86b8097c-6ef9-481c-8cbb-7f50c4c2c165', 1),
('501', 'e7c9ba4f-d699-421e-80fa-b64c253b8560', 2),
('502', 'ac5fa931-8ed3-4234-9813-eee99b52d6dc', 1),
('502', '2939945e-8dbd-481a-b1e9-40561550265f', 2),
('502', '5fd4c38c-cb81-44b2-9cd6-8359f016a559', 3),
('502', '7fdfbc98-dcce-4f28-97df-3eff696720c6', 4),
('502', '9dcfb29a-43db-4419-a0d1-4cba7963250e', 1),
('502', 'ac0dbd14-924a-44d1-b652-2227e4ada4f3', 2),
('502', '46fa2085-17fa-4183-9077-7e763932fd97', 3),
('502', '261e06c7-b4f0-42f8-9488-71852258f1c2', 4),
('503', 'e24ee835-f01d-4571-8564-7b85822fe1a8', 1),
('503', 'e8083e8a-cb7e-4c95-bd26-88a35ccf7f93', 2),
('503', '4e2ceb3e-92a9-4467-8e8d-9dca02e795d7', 3),
('503', '4ba6aa3f-76f2-4871-89ca-082ecf37f010', 4),
('503', 'af67df09-a1c8-43b9-98a6-4c29855af7d6', 5),
('503', '07f2dae2-fd42-498d-945c-20c4c3f12f3a', 6),
('503', '0027cca4-0704-46dc-a555-ffc1bd2dd248', 1),
('503', '28f1d06d-8c2d-4e1f-9b73-4655b492a729', 2),
('503', '926df2d8-1b6a-4a18-8d44-f6743f75fb51', 3),
('503', '223db416-f304-4d6f-848d-5e9e27d39d94', 4),
('503', '0606ac40-6fc2-40e9-9786-2bda30b3cd9e', 5),
('503', 'c665e34e-cc1c-4396-bf59-22fe1e2c80ca', 6),
('504', '84a9aabe-5586-4c54-b64d-55171f69e223', 1),
('504', '8389200e-c36c-447e-b8a3-45372560e340', 2),
('504', 'c5a3058c-2085-42dc-b040-63aac654b3e8', 3),
('504', '3008ab6e-dcbe-493c-8d5b-9fbc43bfb29d', 4),
('504', '5c7378c0-856b-4796-a431-d944685c69ed', 5),
('504', '09198524-593b-47c9-a3ac-5538c187a0db', 6),
('504', '52b73421-e1f5-4fd6-ace5-7df7f46ea785', 7),
('504', 'a4cc3e74-02b3-4ade-b0eb-3265417cf395', 8),
('504', '564a2044-a22a-49c8-be45-94bbd56cf675', 1),
('504', '2abb8205-3c5f-4542-9998-8f78fd383dad', 2),
('504', '87549dc1-e43d-4ef7-b649-c9f8779ab61d', 3),
('504', '7ce0f1ae-6282-4882-9c85-92375ecab755', 4),
('504', '882bd3bc-3d21-4dca-9058-8e8af1eefbbb', 5),
('504', 'ed5b8718-6732-4295-a268-987840a3e392', 6),
('504', '63a13e79-d7fc-4080-a762-e881c33aa99c', 7),
('504', 'a9220a45-86f7-4cd7-b3c4-7a00f5c53bf5', 8),
('505', 'cd9f6527-f6c4-4862-8bea-10ebcb3ef300', 1),
('505', '760c7e8c-ec56-4f0c-8cfa-8d2992453301', 2),
('505', '34003460-95ce-4090-8c16-24f89e6f551d', 3),
('505', '4f9de248-f0e7-45c3-8fc9-9f174ce7a632', 4),
('505', '24b9d4b1-39d2-496d-86e1-3bbe71fcb036', 5),
('505', 'eed6328f-be0b-4be8-914a-4a5b94b9b4c1', 6),
('505', 'abbcfe4d-7706-483e-b90d-011b1dd3c33c', 7),
('505', '53a1e00a-1128-41df-9679-c655a731bfef', 8),
('505', 'f91131c8-8be5-40a6-842c-7791d1c7c1c6', 9),
('505', '167589f5-416d-436e-96e6-53626726c5b8', 10),
('505', '9cf659d3-82dd-448e-b48e-c060ca14b23d', 1),
('505', '4b4b915f-7905-4e87-ac5f-32908f59372e', 2),
('505', 'b6e19314-430d-45bb-acdf-d6d1b5698b9e', 3),
('505', '7c92c5f9-be13-4b5b-a0ba-c1ad253bab1d', 4),
('505', '4a62ea73-5856-4635-ab0d-60bedab3a525', 5),
('505', '066adeaf-d5f1-4856-9099-0bfd4e0ba687', 6),
('505', 'f263fc89-2dab-46f6-a7b6-885036c41127', 7),
('505', '2aecd40e-6a58-4ac3-8f00-4336c3c1f5dc', 8),
('505', '69f277ee-9ac1-4a06-a557-7b8016749a3e', 9),
('505', '5ef996a7-bc05-4f22-9ca1-2ab6fdddc9ae', 10),
('506', 'ac8d8459-e8f2-4112-b2cb-ecc5f6775fdf', 1),
('506', '13849085-af52-43ff-bea0-deb1bfecf3e7', 2),
('506', '7ad0b391-8d9f-443d-afc8-e42fadb42a5d', 3),
('506', 'e152d852-2455-4199-98af-b68a09e255c5', 4),
('506', 'ddb2c841-02a7-43f6-a84f-a6683cd59737', 5),
('506', '0d6ffade-d574-48d0-981e-f68f702bda66', 6),
('506', '58e9925d-ce8e-4145-a8a2-d3e015057c78', 7),
('506', 'cd0c1b34-e16a-4db3-a6c4-2f11907a932f', 8),
('506', 'f1d7a758-ef6a-41c4-8132-68755bb319cf', 9),
('506', '1655bff7-70cc-45ef-8fae-cdf9f4a51ef4', 10),
('506', '29d9663b-0f06-4868-9c25-251141b6f0f3', 11),
('506', '37844b97-493c-4207-a33c-88a02d5017fc', 12),
('506', 'b6138c92-ca3a-409b-bbc3-d018105b4757', 1),
('506', 'd20cffaf-5ece-4cfd-b5e5-ae62ad796495', 2),
('506', '644e09e3-0b03-4a08-bbbc-152825104f8a', 3),
('506', '9077fb1c-85fe-4a00-8020-a8403ad50563', 4),
('506', '5afeca1f-9266-47fc-a216-3b054ea1968c', 5),
('506', 'ec92287b-ca3b-47d5-b86c-3d829c85c421', 6),
('506', 'b2315702-5f8d-45fa-9919-b688c6a8bf23', 7),
('506', '2cfda02b-7c71-4b77-ac2f-063344e606d2', 8),
('506', 'fed17858-371a-4fcc-9a8e-be8ae808008b', 9),
('506', 'cd147cf1-66ee-4fcc-b3b4-94acf846ee42', 10),
('506', '72741a0c-61ae-4036-a4f0-97b52c5909a6', 11),
('506', 'd042eb5d-7cde-4b5e-8d06-92b7fe861c96', 12),
('507', 'a299857a-aa62-43a8-8ed9-847f6e2677a9', 1),
('507', '937c80c6-3f3c-4b76-9c41-93d03665a18e', 2),
('507', '2ea185ec-f7f6-49c2-8049-40c554fc4914', 3),
('507', '2e5acad1-6ce0-4c91-bbe3-c89b8e3a39ef', 4),
('507', '07fc2b6a-aaf2-4d0a-8ca2-53700b02bd79', 5),
('507', '8621a8e7-dfa0-4e64-a202-7bf665e8151c', 6),
('507', '4dea3289-27d8-4de9-a4de-fcbd1b05d8a4', 7),
('507', '5e599073-85d4-4d11-971e-624abb3454fa', 8),
('507', '11d16069-b03f-48c2-84d2-e78a79f07a5e', 9),
('507', 'b66e3596-a862-4f25-80cd-429347aee750', 10),
('507', '6370f6ba-5197-4aba-bc0c-15fb98855aa1', 11),
('507', 'e13ab603-ccbd-45d0-a9ed-3d5fb7496f91', 12),
('507', 'fede6b51-5ea8-41ff-8a79-9161ea01b3cc', 13),
('507', '6f8f2d15-c3df-4bf3-abb8-3509dd71e9cd', 14),
('507', '49fa5a68-ed77-49ce-9549-486f50b5dc8f', 15),
('507', 'f6e0c1f1-d081-4880-b563-11ee8caea969', 16),
('507', '7626b3b2-e992-40a6-8b30-af38a1a105c9', 1),
('507', 'd6677e7f-43aa-4705-8788-ed07b2ddaa96', 2),
('507', '9ae2c9d9-29e9-410b-903a-358f2acf2a0f', 3),
('507', 'a33216c3-c3a4-473b-85e8-91ca3ad248c1', 4),
('507', '28ad4e4d-671b-44b4-8166-394e4de6f3c1', 5),
('507', '1ad1d50b-9c68-44fe-91e8-c76633dfa51e', 6),
('507', '1aeee58a-8ff0-40c0-aa89-923507900b4d', 7),
('507', '1d89724e-5928-4b50-8059-a2e28baa8960', 8),
('507', 'c07b996b-59ec-46a4-babf-a857673b020c', 9),
('507', '4ef4b7f5-defd-47af-a3b1-fe347b4f53c6', 10),
('507', '5aa19b7b-4ff8-44d9-86ee-9647920cfada', 11),
('507', '96aa5295-126d-4770-85b7-5fe1093e69a6', 12),
('507', 'e1f710cd-13d0-4422-bd4c-33b0a2d271c7', 13),
('507', 'c4999da4-8928-4996-8438-2f2af2bd6b61', 14),
('508', '1a88e31c-fc17-4a49-b24c-6ada930c68b0', 1),
('508', '1d42c326-226d-4e3a-8a57-9e640072fb3c', 2),
('508', '4b4b957e-2d36-4607-ab0c-6b89099531c4', 3),
('508', 'b5d505b2-ebc4-4039-9947-e8682954976a', 4),
('508', '5afe8ebf-3e15-4037-8411-c8e109a67a71', 5),
('508', '12f7bcda-9343-4260-985c-b627e241397d', 6),
('508', 'd530969e-ebab-4d51-8b1e-8cd17121afb4', 7),
('508', '7203a082-2376-44cf-b2b2-b209b01045c8', 8),
('508', '9e9d7807-d6b0-47ab-b656-b4f853f9739a', 9),
('508', '90490dae-573a-43e1-aca4-9498ff00420b', 10),
('508', '4ed8c466-ac36-46ea-8dfb-7e40f5fcf667', 11),
('508', '422ba121-7173-40ef-aa2e-b2aacc587e37', 12),
('508', 'feb5977b-30bc-4948-8447-f1802325ea10', 13),
('508', 'c49b78e1-6988-4a1b-9c67-a79ef0ffc9ff', 14),
('508', '7576bc09-d60d-41c9-8919-257408174fab', 15),
('508', '12c25eb1-52c4-4089-a336-f276f8d917f0', 16),
('508', '0808630b-3ceb-43e8-916e-540b64d10b02', 1),
('508', '1ca05411-35c0-4590-b78a-d6e0c71f6b81', 2),
('508', '4cd2031e-b7a3-4a4f-ae61-8dfa0348c342', 3),
('508', 'f84a8db5-9824-4b10-9897-9815f8d778de', 4),
('508', '72e545f4-85c2-44a4-bb46-5c9fc707d302', 5),
('508', '73be74e3-41c7-4677-887f-d3dac2ab6a23', 6),
('508', '871239ee-1fef-4ccb-b481-a7dd25584a39', 7),
('508', '73a4140f-41a3-47ee-97bb-c6e37b680eba', 8),
('508', '0c4b209c-8c37-4e38-bfe9-425e474aa986', 9),
('508', 'c312e3bb-000f-40e7-b82b-fc83dbc79b72', 10),
('508', 'bf5f56c9-74cf-4829-8a97-a37da64e21a6', 11),
('508', '847dce05-6e57-4e48-9eb7-c0fcda2e3eeb', 12),
('508', 'f95222a5-3e39-4c9c-abf8-6ad68f933df5', 13),
('508', 'e1307e3c-b684-407b-b1fe-72f095448430', 14),
('508', 'cfa547c2-fa3d-4923-a96b-c3763e0c85d1', 15),
('508', '6c48b530-4174-4395-bca4-ffa19deed24d', 16),
('509', '22170b8e-850d-45f8-867c-c058dd46e1e6', 1),
('509', '496171db-c5fd-494e-b4c6-74b72f40f0cf', 2),
('509', '50a82b7e-0034-4979-aeea-2a6d5c105c7c', 3),
('509', 'f6745816-8178-4e2b-b230-e6514822e62d', 4),
('509', '9554cabe-0bcf-4635-8c4e-6da66b5f7efd', 5),
('509', 'ba58e506-7043-4c19-a019-3763f3e38e10', 6),
('509', 'fb8947d5-2b35-43a8-8785-4500b4da21b7', 7),
('509', 'de7cc7d2-5d6f-449d-966b-44de6335fecd', 8),
('509', 'f4263dad-7e99-4eea-96d6-c6e6f2e7b5be', 9),
('509', '696c5f30-09a6-4259-b6eb-5d4df16d83fa', 10),
('509', 'ee2e034c-ee00-403e-bed4-dc9c6b9f35b0', 11),
('509', 'a48efed7-aa8a-4a00-b954-348a8ce16919', 12),
('509', '5d62275c-c941-4307-9aef-71ac0712b895', 13),
('509', 'f065064b-f024-4907-a68f-f639ab5004df', 14),
('509', 'de1409f6-8b21-4c5f-a79d-8cc9a234e16d', 15),
('509', 'b79a9ef2-d522-407c-ac69-4365fdcb33df', 16),
('509', 'ee288d73-9245-43f0-a622-cd89193d92ea', 17),
('509', '1a638ae7-aa8a-47dc-8497-ac1574593748', 18),
('509', '10116ddc-4a7a-4ce9-b570-a688ca5e1b26', 1),
('509', '40ce669a-e9de-4555-aa46-a03efe7b70c3', 2),
('509', '40471c37-362c-4e79-9eb1-968cf5c16c49', 3),
('509', '914d0ba8-d645-4e30-b10e-11500896bdf3', 4),
('509', '7ba19a3a-589d-4ebc-bc78-d382726006e5', 5),
('509', '4695aa52-12d8-4461-a395-b17ddd87683a', 6),
('509', 'eac00128-a41a-4559-8bfd-0ca8f668d0af', 7),
('509', 'ca0727fc-2e16-4856-a0a2-5796056cc3dc', 8),
('509', '62752afe-5903-45b7-aa43-49f1049186fd', 9),
('509', 'd251f4bc-f1ef-4308-96bf-f443104a2495', 10),
('509', '288831fd-b8db-402f-9c47-96e6e54a0a38', 11),
('509', 'a07e97e4-53d4-492a-99a9-1589d002e25f', 12),
('509', 'ca70f383-b1cd-4f6c-90f0-cf10cf35ee45', 13),
('509', '495e2ac8-341b-40db-a32c-746f0a7c44a5', 14),
('509', '2e94bfee-c75d-44b0-b632-92c8730ac77b', 15),
('509', '6a099e39-4ec7-45d7-a086-26862e16094e', 16),
('509', 'c180feca-3955-4172-b106-0592cfa3e2d6', 17),
('509', '337b4c5f-de3b-47ac-839b-fbff4b9dca82', 18)
ON CONFLICT (frame_code, guid) DO NOTHING;

-- ====== 3. Conversione posizioni frutti guid -> intero ======

UPDATE quotation_item_fruit_positions p
SET "position" = m.slot_int::varchar
FROM quotation_item_fruits qif
JOIN quotation_items qi ON qi.quotation_item_id = qif.quotation_item_id
JOIN products pr ON pr.product_id = qi.product_id
JOIN models mo ON mo.model_id = pr.model_id
JOIN tmp_slot_guid_map m ON m.frame_code = mo.code
WHERE p.quotation_item_fruit_id = qif.quotation_item_fruit_id
  AND p."position" = m.guid;

COMMIT;

-- ====== 4. Verifiche post-migrazione (eseguire a mano) ======
--
-- Posizioni NON convertite (attese 0 righe, o solo orfani da analizzare):
-- SELECT p.* FROM quotation_item_fruit_positions p WHERE p."position" !~ '^[0-9]+$';
--
-- Controllo incrociato con la colonna "order" (slot_int atteso = order + 1):
-- SELECT count(*) FROM quotation_item_fruit_positions
-- WHERE "position" ~ '^[0-9]+$' AND "order" IS NOT NULL AND "position"::int <> "order" + 1;
--
-- Quando tutto è verificato:
-- DROP TABLE tmp_slot_guid_map;
--
-- NB: se il seed era già stato eseguito con la versione precedente di questo
-- file (margini assoluti), riallineare i margini con:
-- DELETE FROM frame_blocks; e rieseguire la sola sezione 1.
