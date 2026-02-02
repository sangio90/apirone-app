ALTER TABLE quotation_items
ADD COLUMN article_id UUID;

ALTER TABLE quotation_items
ADD CONSTRAINT quotation_items_articles_fk FOREIGN KEY (article_id) REFERENCES articles (article_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;
