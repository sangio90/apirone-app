ALTER TABLE public.reports
  ADD COLUMN code UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE;

  ALTER TABLE public.reports
  DROP COLUMN report_id;

ALTER TABLE public.reports
  RENAME COLUMN code TO report_id;

ALTER TABLE public.reports
  DROP CONSTRAINT reports_code_key RESTRICT;

ALTER TABLE public.reports
  ADD PRIMARY KEY (report_id);  



-- Create a temporary table

CREATE LOCAL TEMPORARY TABLE reports0orskd (
  report VARCHAR(300),
  example_data TEXT,
  created_at TIMESTAMP WITHOUT TIME ZONE STORAGE PLAIN,
  file_name VARCHAR(125),
  category_id VARCHAR(5),
  example_file VARCHAR(125),
  status_id VARCHAR(5),
  report_id UUID STORAGE PLAIN
) ;

-- Copy the source table's data to the temporary table

INSERT INTO reports0orskd (report, example_data, created_at, file_name, category_id, example_file, status_id, report_id) OVERRIDING SYSTEM VALUE
SELECT report, example_data, created_at, file_name, category_id, example_file, status_id, report_id FROM public.reports;

-- Drop the source table

DROP TABLE public.reports;

-- Create the destination table

CREATE TABLE public.reports (
  report_id UUID STORAGE PLAIN DEFAULT uuid_generate_v4() NOT NULL,
  report VARCHAR(300),
  example_data TEXT,
  created_at TIMESTAMP WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now(),
  file_name VARCHAR(125),
  category_id VARCHAR(5),
  example_file VARCHAR(125),
  status_id VARCHAR(5),
  CONSTRAINT reports_pkey PRIMARY KEY(report_id),
  CONSTRAINT reports_status_id_fk FOREIGN KEY (status_id)
    REFERENCES public.statuses(status_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE
) ;

-- Copy the temporary table's data to the destination table

INSERT INTO public.reports (report_id, report, example_data, created_at, file_name, category_id, example_file, status_id) OVERRIDING SYSTEM VALUE
SELECT report_id, report, example_data, created_at, file_name, category_id, example_file, status_id FROM reports0orskd;
