ALTER TABLE quotations
ADD COLUMN opportunity_id UUID,
ADD COLUMN lead_id UUID,
DROP COLUMN opportunity_name,
DROP COLUMN lead_name;