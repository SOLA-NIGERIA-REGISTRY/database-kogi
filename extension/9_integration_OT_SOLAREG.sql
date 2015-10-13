--
-- Name: opentenure; Type: SCHEMA; Schema: -; Owner: postgres
--
DROP SCHEMA IF EXISTS opentenure CASCADE;

CREATE SCHEMA opentenure;


ALTER SCHEMA opentenure OWNER TO postgres;

--
-- Name: SCHEMA opentenure; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA opentenure IS 'This schema holds objects purely related to OpenTenure feature of SOLA';




SET search_path = opentenure, pg_catalog;

--
-- Name: f_for_trg_set_default(); Type: FUNCTION; Schema: opentenure; Owner: postgres
--

CREATE FUNCTION f_for_trg_set_default() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN  
  IF (TG_WHEN = 'AFTER') THEN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        IF (NEW.is_default) THEN
            UPDATE opentenure.form_template SET is_default = 'f' WHERE is_default = 't' AND name != NEW.name;
        ELSE
	    IF (TG_OP = 'UPDATE' AND (SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't' AND name != OLD.name) < 1) THEN
	         UPDATE opentenure.form_template SET is_default = 't' WHERE name = OLD.name;
	    END IF;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        IF ((SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't' AND name != OLD.name) < 1) THEN
	     UPDATE opentenure.form_template SET is_default = 't' WHERE name IN (SELECT name FROM opentenure.form_template WHERE name != OLD.name LIMIT 1);
        END IF;
    END IF;
    RETURN NULL;
  END IF;
END;
$$;


ALTER FUNCTION opentenure.f_for_trg_set_default() OWNER TO postgres;

--
-- Name: FUNCTION f_for_trg_set_default(); Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON FUNCTION opentenure.f_for_trg_set_default() IS 'This function is to set default flag and have at least 1 form as default.';



SET search_path = opentenure, pg_catalog;

--
-- Name: attachment; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE attachment (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    type_code character varying(20) NOT NULL,
    reference_nr character varying(255),
    document_date date,
    description character varying(255),
    body bytea NOT NULL,
    size bigint NOT NULL,
    mime_type character varying(255) NOT NULL,
    file_name character varying(255) NOT NULL,
    file_extension character varying(5) NOT NULL,
    user_name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.attachment OWNER TO postgres;

--
-- Name: TABLE attachment; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE attachment IS 'Extension to the LADM used by SOLA to store claim files attachments.';


--
-- Name: COLUMN attachment.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.id IS 'Identifier for the attachment.';


--
-- Name: COLUMN attachment.type_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.type_code IS 'Attached document type code.';


--
-- Name: COLUMN attachment.reference_nr; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.reference_nr IS 'Document reference number.';


--
-- Name: COLUMN attachment.document_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.document_date IS 'Document date.';


--
-- Name: COLUMN attachment.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.description IS 'Short document description.';


--
-- Name: COLUMN attachment.body; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.body IS 'Binary content of the attachment.';


--
-- Name: COLUMN attachment.size; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.size IS 'File size.';


--
-- Name: COLUMN attachment.mime_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.mime_type IS 'Mime type of the attachment.';


--
-- Name: COLUMN attachment.file_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.file_name IS 'Actual file name of the attachment.';


--
-- Name: COLUMN attachment.file_extension; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.file_extension IS 'File extension of the attachment. E.g. pdf, tiff, doc, etc';


--
-- Name: COLUMN attachment.user_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.user_name IS 'User''s ID, who has created the attachment.';


--
-- Name: COLUMN attachment.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN attachment.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN attachment.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN attachment.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN attachment.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.change_time IS 'The date and time the row was last modified.';


--
-- Name: attachment_chunk; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE attachment_chunk (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    attachment_id character varying(40) NOT NULL,
    claim_id character varying(40),
    start_position bigint NOT NULL,
    size bigint NOT NULL,
    body bytea NOT NULL,
    md5 character varying(50),
    creation_time timestamp without time zone DEFAULT now() NOT NULL,
    user_name character varying(50) NOT NULL
);


ALTER TABLE opentenure.attachment_chunk OWNER TO postgres;

--
-- Name: TABLE attachment_chunk; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE attachment_chunk IS 'Holds temporary pieces of attachment uploaded on the server. In case of large files, document can be split into smaller pieces (chunks) allowing reliable upload. After all pieces uploaded, client will instruct server to create a document and remove temporary files stored in this table.';


--
-- Name: COLUMN attachment_chunk.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.id IS 'Unique ID of the chunk';


--
-- Name: COLUMN attachment_chunk.attachment_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.attachment_id IS 'Attachment ID, which will be used to create final document object. Used to group all chunks together.';


--
-- Name: COLUMN attachment_chunk.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.claim_id IS 'Claim ID. Used to clean the table when saving claim. It will guarantee that no orphan chunks left in the table.';


--
-- Name: COLUMN attachment_chunk.start_position; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.start_position IS 'Staring position of the byte in the source/destination document';


--
-- Name: COLUMN attachment_chunk.size; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.size IS 'Size of the chunk in bytes.';


--
-- Name: COLUMN attachment_chunk.body; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.body IS 'The content of the chunk.';


--
-- Name: COLUMN attachment_chunk.md5; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.md5 IS 'Checksum of the chunk, calculated using MD5.';


--
-- Name: COLUMN attachment_chunk.creation_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.creation_time IS 'Date and time when chuck was created.';


--
-- Name: COLUMN attachment_chunk.user_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.user_name IS 'User''s id (name), who has loaded the chunk';


--
-- Name: attachment_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE attachment_historic (
    id character varying(40),
    type_code character varying(20),
    reference_nr character varying(255),
    document_date date,
    description character varying(255),
    body bytea,
    size bigint,
    mime_type character varying(255),
    file_name character varying(255),
    file_extension character varying(5),
    user_name character varying(50),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.attachment_historic OWNER TO postgres;

--
-- Name: TABLE attachment_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE attachment_historic IS 'Historic table for opentenure.attachment. Keeps all changes done to the main table.';


--
-- Name: claim; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim (
    id character varying(40) NOT NULL,
    nr character varying(15) NOT NULL,
    lodgement_date timestamp without time zone,
    challenge_expiry_date timestamp without time zone,
    decision_date timestamp without time zone,
    description character varying(250),
    challenged_claim_id character varying(40),
    claimant_id character varying(40) NOT NULL,
    mapped_geometry public.geometry,
    gps_geometry public.geometry,
    status_code character varying(20) DEFAULT 'created'::character varying NOT NULL,
    recorder_name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    type_code character varying(20),
    start_date date,
    land_use_code character varying(20),
    notes character varying(1000),
    north_adjacency character varying(500),
    south_adjacency character varying(500),
    east_adjacency character varying(500),
    west_adjacency character varying(500),
    assignee_name character varying(50),
    rejection_reason_code character varying(20),
    claim_area bigint DEFAULT 0,
    CONSTRAINT enforce_geotype_gps_geometry CHECK ((((public.geometrytype(gps_geometry) = 'POLYGON'::text) OR (public.geometrytype(gps_geometry) = 'POINT'::text)) OR (gps_geometry IS NULL))),
    CONSTRAINT enforce_geotype_mapped_geometry CHECK ((((public.geometrytype(mapped_geometry) = 'POLYGON'::text) OR (public.geometrytype(mapped_geometry) = 'POINT'::text)) OR (mapped_geometry IS NULL))),
    CONSTRAINT enforce_valid_gps_geometry CHECK (public.st_isvalid(gps_geometry)),
    CONSTRAINT enforce_valid_mapped_geometry CHECK (public.st_isvalid(mapped_geometry))
);


ALTER TABLE opentenure.claim OWNER TO postgres;

--
-- Name: TABLE claim; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim IS 'Main table to store claim and claim challenge information submitted by the community recorders. SOLA Open Tenure extention.';


--
-- Name: COLUMN claim.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.id IS 'Identifier for the claim.';


--
-- Name: COLUMN claim.nr; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.nr IS 'Auto generated claim number. Generated by the generate-claim-nr business rule when the claim record is initially saved.';


--
-- Name: COLUMN claim.lodgement_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.lodgement_date IS 'The lodgement date and time of the claim.';


--
-- Name: COLUMN claim.challenge_expiry_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.challenge_expiry_date IS 'Expiration date when challenge claim can be submitted.';


--
-- Name: COLUMN claim.decision_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.decision_date IS 'The decision date on the claim by the authority.';


--
-- Name: COLUMN claim.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.description IS 'Free description of the claim.';


--
-- Name: COLUMN claim.challenged_claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.challenged_claim_id IS 'The identifier of the challenged claim. If this value is provided, it means the record is a claim challenge type.';


--
-- Name: COLUMN claim.claimant_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.claimant_id IS 'The identifier of the claimant.';


--
-- Name: COLUMN claim.mapped_geometry; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.mapped_geometry IS 'Claimed property geometry calculated using system SRID';


--
-- Name: COLUMN claim.gps_geometry; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.gps_geometry IS 'Claimed property geometry in Lat/Long format';


--
-- Name: COLUMN claim.status_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.status_code IS 'The status of the claim.';


--
-- Name: COLUMN claim.recorder_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.recorder_name IS 'User''s ID, who has created the claim.';


--
-- Name: COLUMN claim.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';


--
-- Name: COLUMN claim.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN claim.type_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.type_code IS 'Type of claim (e.g. ownership, usufruct, occupation).';


--
-- Name: COLUMN claim.start_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.start_date IS 'Start date of right (occupation)';


--
-- Name: COLUMN claim.land_use_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.land_use_code IS 'Land use code';


--
-- Name: COLUMN claim.notes; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.notes IS 'Any note that could be usefully stored as part of the claim';


--
-- Name: COLUMN claim.north_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.north_adjacency IS 'Optional information about adjacency on the north';


--
-- Name: COLUMN claim.south_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.south_adjacency IS 'Optional information about adjacency on the south';


--
-- Name: COLUMN claim.east_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.east_adjacency IS 'Optional information about adjacency on the east';


--
-- Name: COLUMN claim.west_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.west_adjacency IS 'Optional information about adjacency on the west';


--
-- Name: COLUMN claim.assignee_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.assignee_name IS 'User name who is assigned to work with claim';


--
-- Name: COLUMN claim.rejection_reason_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.rejection_reason_code IS 'Rejection reason code.';


--
-- Name: COLUMN claim.claim_area; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.claim_area IS 'Claim area in square meters.';


--
-- Name: claim_comment; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_comment (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    comment character varying(500) NOT NULL,
    comment_user character varying(50) NOT NULL,
    creation_time timestamp without time zone DEFAULT now() NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_comment OWNER TO postgres;

--
-- Name: COLUMN claim_comment.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.id IS 'Identifier for the claim comment.';


--
-- Name: COLUMN claim_comment.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.claim_id IS 'Identifier for the claim.';


--
-- Name: COLUMN claim_comment.comment; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.comment IS 'Comment text.';


--
-- Name: COLUMN claim_comment.comment_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.comment_user IS 'The user id who has created comment.';


--
-- Name: COLUMN claim_comment.creation_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.creation_time IS 'The date and time when comment was created.';


--
-- Name: COLUMN claim_comment.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';


--
-- Name: COLUMN claim_comment.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_comment.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_comment.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_comment.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.change_time IS 'The date and time the row was last modified.';


--
-- Name: claim_comment_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_comment_historic (
    id character varying(40),
    claim_id character varying(40),
    comment character varying(500),
    comment_user character varying(50),
    creation_time timestamp without time zone,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_comment_historic OWNER TO postgres;

--
-- Name: claim_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_historic (
    id character varying(40),
    nr character varying(15),
    lodgement_date timestamp without time zone,
    challenge_expiry_date timestamp without time zone,
    decision_date timestamp without time zone,
    description character varying(250),
    challenged_claim_id character varying(40),
    claimant_id character varying(40),
    mapped_geometry public.geometry,
    gps_geometry public.geometry,
    status_code character varying(20),
    recorder_name character varying(50),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    type_code character varying(20),
    notes character varying(1000),
    start_date date,
    north_adjacency character varying(500),
    south_adjacency character varying(500),
    east_adjacency character varying(500),
    west_adjacency character varying(500),
    assignee_name character varying(50),
    land_use_code character varying(20),
    rejection_reason_code character varying(20),
    claim_area bigint
);


ALTER TABLE opentenure.claim_historic OWNER TO postgres;

--
-- Name: TABLE claim_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_historic IS 'Historic table for the main table with claims opentenure.claim. Keeps all changes done to the main table.';


--
-- Name: claim_location; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_location (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    mapped_location public.geometry NOT NULL,
    gps_location public.geometry,
    description character varying(500),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_geotype_gps_location CHECK ((((public.geometrytype(gps_location) = 'POLYGON'::text) OR (public.geometrytype(gps_location) = 'POINT'::text)) OR (gps_location IS NULL))),
    CONSTRAINT enforce_geotype_mapped_location CHECK (((public.geometrytype(mapped_location) = 'POLYGON'::text) OR (public.geometrytype(mapped_location) = 'POINT'::text))),
    CONSTRAINT enforce_valid_gps_location CHECK (public.st_isvalid(gps_location)),
    CONSTRAINT enforce_valid_mapped_location CHECK (public.st_isvalid(mapped_location))
);


ALTER TABLE opentenure.claim_location OWNER TO postgres;

--
-- Name: COLUMN claim_location.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.id IS 'Identifier for the claim location.';


--
-- Name: COLUMN claim_location.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.claim_id IS 'Identifier for the claim.';


--
-- Name: COLUMN claim_location.mapped_location; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.mapped_location IS 'Additional claim location geometry.';


--
-- Name: COLUMN claim_location.gps_location; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.gps_location IS 'Additional claim location geometry in Lat/Long format.';


--
-- Name: COLUMN claim_location.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.description IS 'Claim location description.';


--
-- Name: COLUMN claim_location.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';


--
-- Name: COLUMN claim_location.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_location.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_location.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_location.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.change_time IS 'The date and time the row was last modified.';


--
-- Name: claim_location_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_location_historic (
    id character varying(40),
    claim_id character varying(40),
    mapped_location public.geometry,
    gps_location public.geometry,
    description character varying(500),
    rowidentifier character varying(40),
    rowversion integer NOT NULL,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_location_historic OWNER TO postgres;

--
-- Name: claim_nr_seq; Type: SEQUENCE; Schema: opentenure; Owner: postgres
--

CREATE SEQUENCE claim_nr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE opentenure.claim_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE claim_nr_seq; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON SEQUENCE claim_nr_seq IS 'Sequence number used as the basis for the claim nr field. This sequence is used by the generate-claim-nr business rule.';


--
-- Name: claim_share; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_share (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    nominator smallint,
    denominator smallint,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    percentage double precision
);


ALTER TABLE opentenure.claim_share OWNER TO postgres;

--
-- Name: TABLE claim_share; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_share IS 'Identifies the share a party has in a claim.';


--
-- Name: COLUMN claim_share.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.id IS 'Identifier for the claim share.';


--
-- Name: COLUMN claim_share.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.claim_id IS 'Identifier of the claim the share is assocaited with.';


--
-- Name: COLUMN claim_share.nominator; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.nominator IS 'Nominiator part of the share (i.e. top number of fraction)';


--
-- Name: COLUMN claim_share.denominator; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.denominator IS 'Denominator part of the share (i.e. bottom number of fraction)';


--
-- Name: COLUMN claim_share.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.rowidentifier IS 'Identifies the all change records for the row in the claim_share_historic table';


--
-- Name: COLUMN claim_share.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_share.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_share.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_share.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN claim_share.percentage; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.percentage IS 'Percentage of the share. Another form of nominator/denominator presentation.';


--
-- Name: claim_share_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_share_historic (
    id character varying(40),
    claim_id character varying(40),
    nominator smallint,
    denominator smallint,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    percentage double precision
);


ALTER TABLE opentenure.claim_share_historic OWNER TO postgres;

--
-- Name: claim_status; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_status (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.claim_status OWNER TO postgres;

--
-- Name: TABLE claim_status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_status IS 'Code list of claim status.';


--
-- Name: COLUMN claim_status.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.code IS 'The code for the claim status.';


--
-- Name: COLUMN claim_status.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.display_value IS 'Displayed value of the claim status.';


--
-- Name: COLUMN claim_status.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.status IS 'Status of the service claim.';


--
-- Name: COLUMN claim_status.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.description IS 'Description of the claim status.';


--
-- Name: claim_uses_attachment; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_uses_attachment (
    claim_id character varying(40) NOT NULL,
    attachment_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_uses_attachment OWNER TO postgres;

--
-- Name: TABLE claim_uses_attachment; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_uses_attachment IS 'Links the claim to the attachment submitted with the claim. SOLA Open Tenure extension.';


--
-- Name: COLUMN claim_uses_attachment.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.claim_id IS 'Identifier for the claim the record is associated to.';


--
-- Name: COLUMN claim_uses_attachment.attachment_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.attachment_id IS 'Identifier of the attachment associated to the claim.';


--
-- Name: COLUMN claim_uses_attachment.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.rowidentifier IS 'Unique row identifier.';


--
-- Name: COLUMN claim_uses_attachment.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_uses_attachment.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_uses_attachment.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_uses_attachment.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.change_time IS 'The date and time the row was last modified.';


--
-- Name: claim_uses_attachment_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_uses_attachment_historic (
    claim_id character varying(40),
    attachment_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer NOT NULL,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_uses_attachment_historic OWNER TO postgres;

--
-- Name: TABLE claim_uses_attachment_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_uses_attachment_historic IS 'Historic table for opentenure.claim_uses_attachment. Keeps all changes done to the main table.';


--
-- Name: field_constraint; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    error_msg character varying(255) NOT NULL,
    format character varying(255),
    min_value numeric(20,10),
    max_value numeric(20,10),
    field_constraint_type character varying(255) NOT NULL,
    field_template_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_constraint OWNER TO postgres;

--
-- Name: TABLE field_constraint; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_constraint IS 'Dynamic form field constraint.';


--
-- Name: COLUMN field_constraint.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.id IS 'Primary key.';


--
-- Name: COLUMN field_constraint.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_constraint.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN field_constraint.error_msg; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.error_msg IS 'Error message to display in case of constraint violation.';


--
-- Name: COLUMN field_constraint.format; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.format IS 'Regular expression, used to check field value';


--
-- Name: COLUMN field_constraint.min_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.min_value IS 'Minimum field value, used in range constraint.';


--
-- Name: COLUMN field_constraint.max_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.max_value IS 'Maximum field value, used in range constraint.';


--
-- Name: COLUMN field_constraint.field_constraint_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.field_constraint_type IS 'Type of constraint.';


--
-- Name: COLUMN field_constraint.field_template_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.field_template_id IS 'Field template id, which constraint relates to.';


--
-- Name: field_constraint_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    error_msg character varying(255),
    format character varying(255),
    min_value numeric(20,10),
    max_value numeric(20,10),
    field_constraint_type character varying(255),
    field_template_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_constraint_historic OWNER TO postgres;

--
-- Name: field_constraint_option; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_option (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    field_constraint_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer DEFAULT 1 NOT NULL
);


ALTER TABLE opentenure.field_constraint_option OWNER TO postgres;

--
-- Name: TABLE field_constraint_option; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_constraint_option IS 'Dynamic form field constraint option, used to limit field values.';


--
-- Name: COLUMN field_constraint_option.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.id IS 'Primary key.';


--
-- Name: COLUMN field_constraint_option.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_constraint_option.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.display_name IS 'Value to be used as a visible text of UI component.';


--
-- Name: COLUMN field_constraint_option.field_constraint_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.field_constraint_id IS 'Field constraint ID.';


--
-- Name: COLUMN field_constraint_option.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN field_constraint_option.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN field_constraint_option.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN field_constraint_option.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN field_constraint_option.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN field_constraint_option.item_order; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.item_order IS 'Field constraint option ordering number.';


--
-- Name: field_constraint_option_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_option_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    field_constraint_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer
);


ALTER TABLE opentenure.field_constraint_option_historic OWNER TO postgres;

--
-- Name: field_constraint_type; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_type (
    code character varying(255) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.field_constraint_type OWNER TO postgres;

--
-- Name: TABLE field_constraint_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_constraint_type IS 'Reference table for the field constraint types, used in dynamic forms.';


--
-- Name: COLUMN field_constraint_type.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.code IS 'The code for the constraint type.';


--
-- Name: COLUMN field_constraint_type.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.display_value IS 'Displayed value of the constraint type.';


--
-- Name: COLUMN field_constraint_type.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.status IS 'Status of the constraint type.';


--
-- Name: COLUMN field_constraint_type.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.description IS 'Description of the constraint type.';


--
-- Name: field_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_payload (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    field_type character varying(255) NOT NULL,
    section_element_payload_id character varying(40) NOT NULL,
    string_payload character varying(2048),
    big_decimal_payload numeric(20,10),
    boolean_payload boolean,
    field_value_type character varying(255) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer DEFAULT 1 NOT NULL
);


ALTER TABLE opentenure.field_payload OWNER TO postgres;

--
-- Name: TABLE field_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_payload IS 'Dynamic form field payload.';


--
-- Name: COLUMN field_payload.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.id IS 'Primary key.';


--
-- Name: COLUMN field_payload.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_payload.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.display_name IS 'Value to be used as a visible text of UI component.';


--
-- Name: COLUMN field_payload.field_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.field_type IS 'Field type code.';


--
-- Name: COLUMN field_payload.section_element_payload_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.section_element_payload_id IS 'Section element id.';


--
-- Name: COLUMN field_payload.string_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.string_payload IS 'String field value.';


--
-- Name: COLUMN field_payload.big_decimal_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.big_decimal_payload IS 'Decimal or integer field value.';


--
-- Name: COLUMN field_payload.boolean_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.boolean_payload IS 'Boolean field value.';


--
-- Name: COLUMN field_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN field_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN field_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN field_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN field_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN field_payload.item_order; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.item_order IS 'Field ordering number.';


--
-- Name: field_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_payload_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    field_type character varying(255),
    section_element_payload_id character varying(40),
    string_payload character varying(2048),
    big_decimal_payload numeric(20,10),
    boolean_payload boolean,
    field_value_type character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer
);


ALTER TABLE opentenure.field_payload_historic OWNER TO postgres;

--
-- Name: field_template; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_template (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    hint character varying(255),
    field_type character varying(255) NOT NULL,
    section_template_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer DEFAULT 1 NOT NULL
);


ALTER TABLE opentenure.field_template OWNER TO postgres;

--
-- Name: TABLE field_template; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_template IS 'Dynamic form field template.';


--
-- Name: COLUMN field_template.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.id IS 'Primary key.';


--
-- Name: COLUMN field_template.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_template.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN field_template.hint; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.hint IS 'Field hint to be used for UI component.';


--
-- Name: COLUMN field_template.field_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.field_type IS 'Field type code.';


--
-- Name: COLUMN field_template.section_template_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.section_template_id IS 'Section template ID.';


--
-- Name: COLUMN field_template.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN field_template.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN field_template.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN field_template.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN field_template.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN field_template.item_order; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.item_order IS 'Field ordering number.';


--
-- Name: field_template_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_template_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    hint character varying(255),
    field_type character varying(255),
    section_template_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer
);


ALTER TABLE opentenure.field_template_historic OWNER TO postgres;

--
-- Name: field_type; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_type (
    code character varying(255) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.field_type OWNER TO postgres;

--
-- Name: TABLE field_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_type IS 'Reference table for the field types, used in dynamic forms.';


--
-- Name: COLUMN field_type.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.code IS 'The code for the field type.';


--
-- Name: COLUMN field_type.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.display_value IS 'Displayed value of the field type.';


--
-- Name: COLUMN field_type.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.status IS 'Status of the field type.';


--
-- Name: COLUMN field_type.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.description IS 'Description of the field type.';


--
-- Name: field_value_type; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_value_type (
    code character varying(255) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.field_value_type OWNER TO postgres;

--
-- Name: TABLE field_value_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_value_type IS 'Reference table for the field value types, used in dynamic forms.';


--
-- Name: COLUMN field_value_type.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.code IS 'The code for the field value type.';


--
-- Name: COLUMN field_value_type.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.display_value IS 'Displayed value of the field value type.';


--
-- Name: COLUMN field_value_type.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.status IS 'Status of the field value type.';


--
-- Name: COLUMN field_value_type.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.description IS 'Description of the field value type.';


--
-- Name: form_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_payload (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    form_template_name character varying(255) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_payload OWNER TO postgres;

--
-- Name: TABLE form_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE form_payload IS 'Dynamic form payload.';


--
-- Name: COLUMN form_payload.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.id IS 'Primary key.';


--
-- Name: COLUMN form_payload.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.claim_id IS 'Foreign key to the parent claim object.';


--
-- Name: COLUMN form_payload.form_template_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.form_template_name IS 'Foreign key to relevant dynamic form template.';


--
-- Name: COLUMN form_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN form_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN form_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN form_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN form_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: form_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_payload_historic (
    id character varying(40),
    claim_id character varying(40),
    form_template_name character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_payload_historic OWNER TO postgres;

--
-- Name: form_template; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_template (
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_template OWNER TO postgres;

--
-- Name: TABLE form_template; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE form_template IS 'Dynamic form template.';


--
-- Name: COLUMN form_template.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.display_name IS 'Form name, which can be used for displaying on the UI.';


--
-- Name: COLUMN form_template.is_default; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.is_default IS 'Indicates whether form is default for all new claims.';


--
-- Name: COLUMN form_template.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN form_template.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN form_template.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN form_template.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN form_template.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.change_time IS 'The date and time the row was last modified.';


--
-- Name: form_template_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_template_historic (
    name character varying(255),
    display_name character varying(255),
    is_default boolean,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_template_historic OWNER TO postgres;

--
-- Name: party; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255) NOT NULL,
    last_name character varying(50),
    id_type_code character varying(20),
    id_number character varying(20),
    birth_date date,
    gender_code character varying(20),
    mobile_phone character varying(15),
    phone character varying(15),
    email character varying(50),
    address character varying(255),
    user_name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    is_person boolean DEFAULT true NOT NULL
);


ALTER TABLE opentenure.party OWNER TO postgres;

--
-- Name: TABLE party; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE party IS 'Extension to the LADM used by SOLA to store party information (cliamant or owner).';


--
-- Name: COLUMN party.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.id IS 'Unique identifier for the party.';


--
-- Name: COLUMN party.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.name IS 'First name of party.';


--
-- Name: COLUMN party.last_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.last_name IS 'Last name of claimant.';


--
-- Name: COLUMN party.id_type_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.id_type_code IS 'ID document type code';


--
-- Name: COLUMN party.id_number; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.id_number IS 'ID document number.';


--
-- Name: COLUMN party.birth_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.birth_date IS 'Date of birth of the party.';


--
-- Name: COLUMN party.gender_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.gender_code IS 'Gender code of the party.';


--
-- Name: COLUMN party.mobile_phone; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.mobile_phone IS 'Mobile phone number of the party.';


--
-- Name: COLUMN party.phone; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.phone IS 'Landline phone number of the party.';


--
-- Name: COLUMN party.email; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.email IS 'Email address of the party.';


--
-- Name: COLUMN party.address; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.address IS 'Living address of the party.';


--
-- Name: COLUMN party.user_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.user_name IS 'User name who has created the record.';


--
-- Name: COLUMN party.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN party.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN party.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN party.is_person; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.is_person IS 'Indicates if record is for individual or company (legal entity)';


--
-- Name: party_for_claim_share; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_claim_share (
    party_id character varying(40) NOT NULL,
    claim_share_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.party_for_claim_share OWNER TO postgres;

--
-- Name: TABLE party_for_claim_share; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE party_for_claim_share IS 'Identifies parties involved in the claim share.';


--
-- Name: COLUMN party_for_claim_share.party_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.party_id IS 'Identifier for the party.';


--
-- Name: COLUMN party_for_claim_share.claim_share_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.claim_share_id IS 'Identifier of the claim share.';


--
-- Name: COLUMN party_for_claim_share.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.rowidentifier IS 'Identifies the all change records for the row in the party_for_claim_share_historic table';


--
-- Name: COLUMN party_for_claim_share.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_for_claim_share.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_for_claim_share.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN party_for_claim_share.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.change_time IS 'The date and time the row was last modified.';


--
-- Name: party_for_claim_share_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_claim_share_historic (
    party_id character varying(40),
    claim_share_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.party_for_claim_share_historic OWNER TO postgres;

--
-- Name: party_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party_historic (
    id character varying(40),
    name character varying(255),
    last_name character varying(50),
    id_type_code character varying(20),
    id_number character varying(20),
    birth_date date,
    gender_code character varying(20),
    mobile_phone character varying(15),
    phone character varying(15),
    email character varying(50),
    address character varying(255),
    user_name character varying(50),
    rowidentifier character varying(40),
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    is_person boolean
);


ALTER TABLE opentenure.party_historic OWNER TO postgres;

--
-- Name: TABLE party_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE party_historic IS 'Historic table for opentenure.party. Keeps all changes done to the main table.';


--
-- Name: rejection_reason; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE rejection_reason (
    code character varying(20) NOT NULL,
    display_value character varying(2000) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.rejection_reason OWNER TO postgres;

--
-- Name: TABLE rejection_reason; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE rejection_reason IS 'Rejection reason codes';


--
-- Name: COLUMN rejection_reason.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.code IS 'The code for the rejection reason.';


--
-- Name: COLUMN rejection_reason.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.display_value IS 'Displayed value of the rejection reason.';


--
-- Name: COLUMN rejection_reason.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.status IS 'Status of the rejection reason.';


--
-- Name: COLUMN rejection_reason.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.description IS 'Description of the rejection reason.';


--
-- Name: section_element_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_element_payload (
    id character varying(40) NOT NULL,
    section_payload_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_element_payload OWNER TO postgres;

--
-- Name: TABLE section_element_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE section_element_payload IS 'Dynamic form section element payload.';


--
-- Name: COLUMN section_element_payload.section_payload_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.section_payload_id IS 'Section payload ID.';


--
-- Name: COLUMN section_element_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN section_element_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN section_element_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN section_element_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN section_element_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: section_element_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_element_payload_historic (
    id character varying(40),
    section_payload_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_element_payload_historic OWNER TO postgres;

--
-- Name: section_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_payload (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    element_name character varying(255) NOT NULL,
    element_display_name character varying(255) NOT NULL,
    min_occurrences integer NOT NULL,
    max_occurrences integer NOT NULL,
    form_payload_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer DEFAULT 1 NOT NULL
);


ALTER TABLE opentenure.section_payload OWNER TO postgres;

--
-- Name: TABLE section_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE section_payload IS 'Dynamic form section payload.';


--
-- Name: COLUMN section_payload.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.id IS 'Primary key.';


--
-- Name: COLUMN section_payload.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.name IS 'Section name to be used as UI component name.';


--
-- Name: COLUMN section_payload.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN section_payload.element_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.element_name IS 'Section element name to be used as UI component name.';


--
-- Name: COLUMN section_payload.element_display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.element_display_name IS 'Text value to be used as a visible label of the section element UI component.';


--
-- Name: COLUMN section_payload.min_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.min_occurrences IS 'Minimum occurane of the section elements on the form.';


--
-- Name: COLUMN section_payload.max_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.max_occurrences IS 'Maximum occurane of the section elements on the form. If max > 1, UI will be shown as a table.';


--
-- Name: COLUMN section_payload.form_payload_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.form_payload_id IS 'Foreign key reference to form payload.';


--
-- Name: COLUMN section_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN section_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN section_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN section_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN section_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN section_payload.item_order; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.item_order IS 'Section ordering number.';


--
-- Name: section_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_payload_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    element_name character varying(255),
    element_display_name character varying(255),
    min_occurrences integer,
    max_occurrences integer,
    form_payload_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer
);


ALTER TABLE opentenure.section_payload_historic OWNER TO postgres;

--
-- Name: section_template; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_template (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    error_msg character varying(255) NOT NULL,
    min_occurrences integer NOT NULL,
    max_occurrences integer NOT NULL,
    form_template_name character varying(255) NOT NULL,
    element_name character varying(255) NOT NULL,
    element_display_name character varying(255) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer DEFAULT 1 NOT NULL
);


ALTER TABLE opentenure.section_template OWNER TO postgres;

--
-- Name: TABLE section_template; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE section_template IS 'Sections of dynamic form template.';


--
-- Name: COLUMN section_template.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.name IS 'Section name to be used as UI component name.';


--
-- Name: COLUMN section_template.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN section_template.error_msg; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.error_msg IS 'Error message to show when min/max conditions are not met.';


--
-- Name: COLUMN section_template.min_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.min_occurrences IS 'Minimum occurane of the section elements on the form.';


--
-- Name: COLUMN section_template.max_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.max_occurrences IS 'Maximum occurane of the section elements on the form. If max > 1, UI will be shown as a table.';


--
-- Name: COLUMN section_template.form_template_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.form_template_name IS 'Foreign key reference to form template.';


--
-- Name: COLUMN section_template.element_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.element_name IS 'Section element name to be used as UI component name.';


--
-- Name: COLUMN section_template.element_display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.element_display_name IS 'Text value to be used as a visible label of the section element UI component.';


--
-- Name: COLUMN section_template.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN section_template.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN section_template.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN section_template.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN section_template.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN section_template.item_order; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.item_order IS 'Section ordering number.';


--
-- Name: section_template_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_template_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    error_msg character varying(255),
    min_occurrences integer,
    max_occurrences integer,
    form_template_name character varying(255),
    element_name character varying(255),
    element_display_name character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    item_order integer
);


ALTER TABLE opentenure.section_template_historic OWNER TO postgres;



SET search_path = opentenure, pg_catalog;

--
-- Name: attachment_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- Name: claim_comment_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_comment
    ADD CONSTRAINT claim_comment_pkey PRIMARY KEY (id);


--
-- Name: claim_location_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_location
    ADD CONSTRAINT claim_location_pkey PRIMARY KEY (id);


--
-- Name: claim_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_pkey PRIMARY KEY (id);


--
-- Name: claim_share_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_share
    ADD CONSTRAINT claim_share_pkey PRIMARY KEY (id);


--
-- Name: claim_status_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_status
    ADD CONSTRAINT claim_status_display_value_unique UNIQUE (display_value);


--
-- Name: claim_status_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_status
    ADD CONSTRAINT claim_status_pkey PRIMARY KEY (code);


--
-- Name: claim_uses_attachment_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_uses_attachment
    ADD CONSTRAINT claim_uses_attachment_pkey PRIMARY KEY (claim_id, attachment_id);


--
-- Name: claimant_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party
    ADD CONSTRAINT claimant_pkey PRIMARY KEY (id);


--
-- Name: field_constraint_option_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint_option
    ADD CONSTRAINT field_constraint_option_pkey PRIMARY KEY (id);


--
-- Name: field_constraint_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint
    ADD CONSTRAINT field_constraint_pkey PRIMARY KEY (id);


--
-- Name: field_constraint_type_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint_type
    ADD CONSTRAINT field_constraint_type_display_value_unique UNIQUE (display_value);


--
-- Name: field_constraint_type_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint_type
    ADD CONSTRAINT field_constraint_type_pkey PRIMARY KEY (code);


--
-- Name: field_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_pkey PRIMARY KEY (id);


--
-- Name: field_template_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_template
    ADD CONSTRAINT field_template_pkey PRIMARY KEY (id);


--
-- Name: field_type_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_type
    ADD CONSTRAINT field_type_display_value_unique UNIQUE (display_value);


--
-- Name: field_type_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_type
    ADD CONSTRAINT field_type_pkey PRIMARY KEY (code);


--
-- Name: field_value_type_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_value_type
    ADD CONSTRAINT field_value_type_display_value_unique UNIQUE (display_value);


--
-- Name: field_value_type_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_value_type
    ADD CONSTRAINT field_value_type_pkey PRIMARY KEY (code);


--
-- Name: form_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY form_payload
    ADD CONSTRAINT form_payload_pkey PRIMARY KEY (id);


--
-- Name: form_template_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY form_template
    ADD CONSTRAINT form_template_pkey PRIMARY KEY (name);


--
-- Name: id_pkey_document_chunk; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attachment_chunk
    ADD CONSTRAINT id_pkey_document_chunk PRIMARY KEY (id);


--
-- Name: party_for_claim_share_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_for_claim_share
    ADD CONSTRAINT party_for_claim_share_pkey PRIMARY KEY (party_id, claim_share_id);


--
-- Name: rejection_reason_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rejection_reason
    ADD CONSTRAINT rejection_reason_display_value_unique UNIQUE (display_value);


--
-- Name: rejection_reason_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rejection_reason
    ADD CONSTRAINT rejection_reason_pkey PRIMARY KEY (code);


--
-- Name: section_element_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY section_element_payload
    ADD CONSTRAINT section_element_payload_pkey PRIMARY KEY (id);


--
-- Name: section_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY section_payload
    ADD CONSTRAINT section_payload_pkey PRIMARY KEY (id);


--
-- Name: section_template_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY section_template
    ADD CONSTRAINT section_template_pkey PRIMARY KEY (id);


--
-- Name: start_unique_document_chunk; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attachment_chunk
    ADD CONSTRAINT start_unique_document_chunk UNIQUE (attachment_id, start_position);


SET search_path = opentenure, pg_catalog;

--
-- Name: unique_field_constraint_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_constraint_name_idx ON field_constraint USING btree (name, field_template_id);


--
-- Name: unique_field_constraint_option_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_constraint_option_name_idx ON field_constraint_option USING btree (name, field_constraint_id);


--
-- Name: unique_field_payload_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_payload_name_idx ON field_payload USING btree (name, section_element_payload_id);


--
-- Name: unique_field_template_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_template_name_idx ON field_template USING btree (name, section_template_id);


--
-- Name: unique_section_payload_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_section_payload_name_idx ON section_payload USING btree (name, form_payload_id);


--
-- Name: unique_section_template_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_section_template_name_idx ON section_template USING btree (name, form_template_name);



SET search_path = opentenure, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_uses_attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_for_claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_location FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_comment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON form_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON section_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON form_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON section_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_constraint FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_constraint_option FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON section_element_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_uses_attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_for_claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_location FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_comment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON form_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON section_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON form_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON section_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_constraint FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_constraint_option FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON section_element_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: set_default; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER set_default AFTER INSERT OR DELETE OR UPDATE ON form_template FOR EACH ROW EXECUTE PROCEDURE f_for_trg_set_default();



SET search_path = opentenure, pg_catalog;

--
-- Name: claim_claimant_id_fk8; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_claimant_id_fk8 FOREIGN KEY (claimant_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: claim_comment_claim_id_fk8; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_comment
    ADD CONSTRAINT claim_comment_claim_id_fk8 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: claim_fk_type_code; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_fk_type_code FOREIGN KEY (type_code) REFERENCES administrative.rrr_type(code);


--
-- Name: claim_location_claim_id_fk8; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_location
    ADD CONSTRAINT claim_location_claim_id_fk8 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: claim_share_claim_id_fk12; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_share
    ADD CONSTRAINT claim_share_claim_id_fk12 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: claim_status_code_fk18; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_status_code_fk18 FOREIGN KEY (status_code) REFERENCES claim_status(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: claim_uses_attachment_claim_id_fk126; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_uses_attachment
    ADD CONSTRAINT claim_uses_attachment_claim_id_fk126 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_constraint_field_constraint_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_constraint
    ADD CONSTRAINT field_constraint_field_constraint_type_fkey FOREIGN KEY (field_constraint_type) REFERENCES field_constraint_type(code) ON DELETE CASCADE;


--
-- Name: field_constraint_field_template_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_constraint
    ADD CONSTRAINT field_constraint_field_template_id_fkey FOREIGN KEY (field_template_id) REFERENCES field_template(id) ON DELETE CASCADE;


--
-- Name: field_constraint_option_field_constraint_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_constraint_option
    ADD CONSTRAINT field_constraint_option_field_constraint_id_fkey FOREIGN KEY (field_constraint_id) REFERENCES field_constraint(id) ON DELETE CASCADE;


--
-- Name: field_payload_field_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_field_type_fkey FOREIGN KEY (field_type) REFERENCES field_type(code) ON DELETE CASCADE;


--
-- Name: field_payload_field_value_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_field_value_type_fkey FOREIGN KEY (field_value_type) REFERENCES field_value_type(code) ON DELETE CASCADE;


--
-- Name: field_payload_section_element_payload_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_section_element_payload_id_fkey FOREIGN KEY (section_element_payload_id) REFERENCES section_element_payload(id) ON DELETE CASCADE;


--
-- Name: field_template_field_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_template
    ADD CONSTRAINT field_template_field_type_fkey FOREIGN KEY (field_type) REFERENCES field_type(code) ON DELETE CASCADE;


--
-- Name: field_template_section_template_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_template
    ADD CONSTRAINT field_template_section_template_id_fkey FOREIGN KEY (section_template_id) REFERENCES section_template(id) ON DELETE CASCADE;


--
-- Name: fk_challenged_claim; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT fk_challenged_claim FOREIGN KEY (challenged_claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_claim_land_use_type; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT fk_claim_land_use_type FOREIGN KEY (land_use_code) REFERENCES cadastre.land_use_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_claim_rejection_reason_code; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT fk_claim_rejection_reason_code FOREIGN KEY (rejection_reason_code) REFERENCES rejection_reason(code);


--
-- Name: fk_document_type_code; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY attachment
    ADD CONSTRAINT fk_document_type_code FOREIGN KEY (type_code) REFERENCES source.administrative_source_type(code);


--
-- Name: form_payload_claim_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY form_payload
    ADD CONSTRAINT form_payload_claim_id_fkey FOREIGN KEY (claim_id) REFERENCES claim(id) ON DELETE CASCADE;


--
-- Name: form_payload_form_template_name_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY form_payload
    ADD CONSTRAINT form_payload_form_template_name_fkey FOREIGN KEY (form_template_name) REFERENCES form_template(name) ON DELETE CASCADE;


--
-- Name: party_for_claim_share_claim_id_fk43; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY party_for_claim_share
    ADD CONSTRAINT party_for_claim_share_claim_id_fk43 FOREIGN KEY (claim_share_id) REFERENCES claim_share(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_claim_share_party_id_fk23; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY party_for_claim_share
    ADD CONSTRAINT party_for_claim_share_party_id_fk23 FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: section_element_payload_section_payload_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY section_element_payload
    ADD CONSTRAINT section_element_payload_section_payload_id_fkey FOREIGN KEY (section_payload_id) REFERENCES section_payload(id) ON DELETE CASCADE;


--
-- Name: section_payload_form_payload_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY section_payload
    ADD CONSTRAINT section_payload_form_payload_id_fkey FOREIGN KEY (form_payload_id) REFERENCES form_payload(id) ON DELETE CASCADE;


--
-- Name: section_template_form_template_name_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY section_template
    ADD CONSTRAINT section_template_form_template_name_fkey FOREIGN KEY (form_template_name) REFERENCES form_template(name) ON DELETE CASCADE;



----   update in source.administrative_source_type
UPDATE source.administrative_source_type
   SET display_value='Diagram Image'
 WHERE code='cadastralSurvey';



----- update to make dynamic form labels in sola registry as in opentenure
ALTER TABLE administrative.ba_unit_detail
   ALTER COLUMN detail_code TYPE character varying(255);
COMMENT ON COLUMN administrative.ba_unit_detail.detail_code IS 'The type of detail.';

ALTER TABLE administrative.ba_unit_detail_historic
   ALTER COLUMN detail_code TYPE character varying(255);
COMMENT ON COLUMN administrative.ba_unit_detail_historic.detail_code IS 'The type of detail.';

ALTER TABLE administrative.ba_unit_detail_type
   ALTER COLUMN code TYPE character varying(255);
COMMENT ON COLUMN administrative.ba_unit_detail_type.code IS 'The code for the detail type.';


UPDATE administrative.ba_unit_detail_type  SET code='advancePayment' WHERE code='advpayment';
UPDATE administrative.ba_unit_detail_type  SET code='cOfO' WHERE code='cofonum';
UPDATE administrative.ba_unit_detail_type  SET code='dateSigned' WHERE code='dateissued';
UPDATE administrative.ba_unit_detail_type  SET code='dateRegistered' WHERE code='dateregistered';
UPDATE administrative.ba_unit_detail_type  SET code='instrumentRegistrationNo' WHERE code='instrnum';
UPDATE administrative.ba_unit_detail_type  SET code='LGA' WHERE code='lga';
UPDATE administrative.ba_unit_detail_type  SET code='layoutPlan' WHERE code='plan';
UPDATE administrative.ba_unit_detail_type  SET code='plotNum' WHERE code='plot';
UPDATE administrative.ba_unit_detail_type  SET code='cOfOtype' WHERE code='purpose';
UPDATE administrative.ba_unit_detail_type  SET code='yearlyRent' WHERE code='rent';
UPDATE administrative.ba_unit_detail_type  SET code='reviewPeriod' WHERE code='revperiod';
UPDATE administrative.ba_unit_detail_type  SET code='dateCommenced' WHERE code='startdate';


----- update to make dynamic form labels in sola registry as in opentenure
UPDATE administrative.ba_unit_detail  SET detail_code='advancePayment' WHERE detail_code='advpayment';
UPDATE administrative.ba_unit_detail  SET detail_code='cOfO' WHERE detail_code='cofonum';
UPDATE administrative.ba_unit_detail  SET detail_code='dateSigned' WHERE detail_code='dateissued';
UPDATE administrative.ba_unit_detail  SET detail_code='dateRegistered' WHERE detail_code='dateregistered';
UPDATE administrative.ba_unit_detail  SET detail_code='instrumentRegistrationNo' WHERE detail_code='instrnum';
UPDATE administrative.ba_unit_detail  SET detail_code='LGA' WHERE detail_code='lga';
UPDATE administrative.ba_unit_detail  SET detail_code='layoutPlan' WHERE detail_code='plan';
UPDATE administrative.ba_unit_detail  SET detail_code='plotNum' WHERE detail_code='plot';
UPDATE administrative.ba_unit_detail  SET detail_code='cOfOtype' WHERE detail_code='purpose';
UPDATE administrative.ba_unit_detail  SET detail_code='yearlyRent' WHERE detail_code='rent';
UPDATE administrative.ba_unit_detail  SET detail_code='reviewPeriod' WHERE detail_code='revperiod';
UPDATE administrative.ba_unit_detail  SET detail_code='dateCommenced' WHERE detail_code='startdate';