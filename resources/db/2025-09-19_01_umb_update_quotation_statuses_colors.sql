UPDATE statuses
SET color_id = CASE status_id
    WHEN 'LAV' THEN 'C20'
    WHEN 'PRO' THEN 'C40'
    WHEN 'APR' THEN 'C50'
    WHEN 'CON' THEN 'C70'
    WHEN 'PER' THEN 'C80'
    WHEN 'EST' THEN 'C100'
    WHEN 'NEW' THEN 'C10'
    WHEN 'END' THEN 'C90'
END
WHERE status_id IN ('LAV','PRO','APR','CON','PER','EST','NEW','END');