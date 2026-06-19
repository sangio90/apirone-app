-- Aggiunge colonna rotatable a frame_blocks.
-- rotatable = TRUE  → il blocco può essere ruotato in modo indipendente nel preventivo.
-- rotatable = FALSE → il blocco NON può essere ruotato in modo indipendente (default per tutti i blocchi esistenti).
-- L'orientation_mode resta HAV/HOR/VER e controlla solo l'orientamento delle celle.

ALTER TABLE frame_blocks
    ADD COLUMN IF NOT EXISTS rotatable BOOLEAN NOT NULL DEFAULT FALSE;

-- Verifica
SELECT frame_block_id, frame_id, "order", orientation_mode, rotatable
FROM frame_blocks
ORDER BY frame_id, "order";
