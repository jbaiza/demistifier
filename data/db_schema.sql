-- Table: public.children

-- DROP TABLE public.children;

CREATE TABLE public.children
(
    id bigint NOT NULL DEFAULT nextval('children_id_seq'::regclass),
    child_uid character varying COLLATE pg_catalog."default",
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT children_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Table: public.regions

-- DROP TABLE public.regions;

CREATE TABLE public.regions
(
    id bigint NOT NULL DEFAULT nextval('regions_id_seq'::regclass),
    name character varying COLLATE pg_catalog."default",
    code character varying COLLATE pg_catalog."default",
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT regions_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Table: public.institutions

-- DROP TABLE public.institutions;

CREATE TABLE public.institutions
(
    id bigint NOT NULL DEFAULT nextval('institutions_id_seq'::regclass),
    name character varying COLLATE pg_catalog."default",
    alternate_names text COLLATE pg_catalog."default",
    reg_nr character varying COLLATE pg_catalog."default",
    lr_izm_code character varying COLLATE pg_catalog."default",
    address character varying COLLATE pg_catalog."default",
    institution_type character varying COLLATE pg_catalog."default",
    email character varying COLLATE pg_catalog."default",
    url character varying COLLATE pg_catalog."default",
    lat double precision,
    lon double precision,
    institution_id_source integer,
    region_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT institutions_pkey PRIMARY KEY (id),
    CONSTRAINT fk_rails_2b9c7de3dc FOREIGN KEY (region_id)
        REFERENCES public.regions (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Index: index_institutions_on_region_id

-- DROP INDEX public.index_institutions_on_region_id;

CREATE INDEX index_institutions_on_region_id
    ON public.institutions USING btree
    (region_id)
    TABLESPACE pg_default;

-- Table: public.statistic_measures

-- DROP TABLE public.statistic_measures;

CREATE TABLE public.statistic_measures
(
    id bigint NOT NULL DEFAULT nextval('statistic_measures_id_seq'::regclass),
    code character varying COLLATE pg_catalog."default",
    name character varying COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT statistic_measures_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Table: public.statistics

-- DROP TABLE public.statistics;

CREATE TABLE public.statistics
(
    id bigint NOT NULL DEFAULT nextval('statistics_id_seq'::regclass),
    institution_id bigint,
    region_id bigint,
    statistic_measure_id bigint,
    value integer,
    value_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT statistics_pkey PRIMARY KEY (id),
    CONSTRAINT fk_rails_0d3f491433 FOREIGN KEY (region_id)
        REFERENCES public.regions (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_rails_e3af7a213f FOREIGN KEY (institution_id)
        REFERENCES public.institutions (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_rails_f22a34c7cc FOREIGN KEY (statistic_measure_id)
        REFERENCES public.statistic_measures (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Index: index_statistics_on_institution_id

-- DROP INDEX public.index_statistics_on_institution_id;

CREATE INDEX index_statistics_on_institution_id
    ON public.statistics USING btree
    (institution_id)
    TABLESPACE pg_default;

-- Index: index_statistics_on_region_id

-- DROP INDEX public.index_statistics_on_region_id;

CREATE INDEX index_statistics_on_region_id
    ON public.statistics USING btree
    (region_id)
    TABLESPACE pg_default;

-- Index: index_statistics_on_statistic_measure_id

-- DROP INDEX public.index_statistics_on_statistic_measure_id;

CREATE INDEX index_statistics_on_statistic_measure_id
    ON public.statistics USING btree
    (statistic_measure_id)
    TABLESPACE pg_default;

-- Table: public.institution_program_languages

-- DROP TABLE public.institution_program_languages;

CREATE TABLE public.institution_program_languages
(
    id bigint NOT NULL DEFAULT nextval('institution_program_languages_id_seq'::regclass),
    institution_id bigint,
    starting_age character varying COLLATE pg_catalog."default",
    language character varying COLLATE pg_catalog."default",
    language_en character varying COLLATE pg_catalog."default",
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT institution_program_languages_pkey PRIMARY KEY (id),
    CONSTRAINT fk_rails_53f0b71c8a FOREIGN KEY (institution_id)
        REFERENCES public.institutions (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Index: index_institution_program_languages_on_institution_id

-- DROP INDEX public.index_institution_program_languages_on_institution_id;

CREATE INDEX index_institution_program_languages_on_institution_id
    ON public.institution_program_languages USING btree
    (institution_id)
    TABLESPACE pg_default;

-- Table: public.applications

-- DROP TABLE public.applications;

CREATE TABLE public.applications
(
    id bigint NOT NULL DEFAULT nextval('applications_id_seq'::regclass),
    institution_program_language_id bigint,
    child_id bigint,
    registered_date date,
    desirable_start_date date,
    priority_5years_old boolean,
    priority_commission boolean,
    priority_sibling boolean,
    priority_parent_local boolean,
    priority_child_local boolean,
    private_fin_local boolean,
    nanny_fin_local boolean,
    choose_not_to_receive boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT applications_pkey PRIMARY KEY (id),
    CONSTRAINT fk_rails_7e457f448c FOREIGN KEY (institution_program_language_id)
        REFERENCES public.institution_program_languages (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_rails_ab61d6c146 FOREIGN KEY (child_id)
        REFERENCES public.children (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Index: index_applications_on_child_id

-- DROP INDEX public.index_applications_on_child_id;

CREATE INDEX index_applications_on_child_id
    ON public.applications USING btree
    (child_id)
    TABLESPACE pg_default;

-- Index: index_applications_on_institution_program_language_id

-- DROP INDEX public.index_applications_on_institution_program_language_id;

CREATE INDEX index_applications_on_institution_program_language_id
    ON public.applications USING btree
    (institution_program_language_id)
    TABLESPACE pg_default;

alter table regions alter column updated_at set default current_date;
alter table regions alter column created_at set default current_date;
alter table institutions alter column created_at set default current_date;
alter table institutions alter column updated_at set default current_date;
