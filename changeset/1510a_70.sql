--
-- Nigeria SOLA Registry Reference List Customisation
-- 28 October 2015
-- Correction to administrative_source_type 29 October


-- Data for Name: administrative_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

UPDATE source.administrative_source_type SET status = 'x' WHERE code IN ( 'personPhoto', 'taxPayment', 'utilityBill', 'other', 'relationshipTitle', 'pdf',  'waiver',  'cadastralMap', 'agriConsent', 'tiff', 'jpg',
 'agriLease', 'tif', 'publicNotification', 'restrictionOrder', 'parcelPlan', 'standardDocument', 'surveyDataFile', 'systematicRegn', 'objection', 'agriNotaryStatement');

UPDATE source.administrative_source_type SET status = 'c' WHERE code IN ('courtOrder', 'mortgage', 'powerOfAttorney', 'proclamation', 'will', 'caveat',   'lease', 'deed', 'officeNote', 'agreement', 'contractForSale', 
'requisition', 'idVerification', 'title', 'cadastralSurvey' );


UPDATE administrative.ba_unit_rel_type  SET display_value = 'Sub-lease::::Договор Аренды::::إيجار::::Bail::::Arrendar::::Arrendamento::::租赁' WHERE code = 'lease';
UPDATE administrative.ba_unit_rel_type  SET display_value = 'Certificate of Birth Death and Marriage::::::::شهادة حيوية::::::::::::::::重要证书' WHERE code = 'relationshipTitle';
UPDATE administrative.ba_unit_rel_type  SET display_value = 'Certificate of Occupancy::::Право Собственности::::سند ملكية::::Titre::::Titulo::::Título::::产权' WHERE code = 'title';


-- Data for Name: ba_unit_rel_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--
UPDATE administrative.ba_unit_rel_type  SET display_value = 'Prior CofO::::Предыдущая недвижимость::::سند الملكية السابق::::Titre précédent::::::::::::Título Prévio' WHERE code = 'priorTitle';
UPDATE administrative.ba_unit_rel_type  SET display_value = 'First CofO::::Корневая недвижимость::::أصل  سند الملكية::::Racine du Titre::::::::::::Origem do Título' WHERE code = 'rootTitle';


-- Data for Name: ba_unit_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--
UPDATE administrative.ba_unit_type SET status = 'x' WHERE code IN ('administrativeUnit', 'leasedUnit', 'propertyRightUnit');


-- Data for Name: mortgage_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--
UPDATE administrative.mortgage_type SET status = 'x' WHERE code IN ('microCredit');

UPDATE administrative.mortgage_type  SET display_value = 'Fixed Repayments::::Многоуровневый платеж::::دفعات متدرجة::::Niveau de Paiement::::::::::::Nível de Pagamento' WHERE code = 'levelPayment';
UPDATE administrative.mortgage_type  SET display_value = 'Fixed plus Interest Repayments::::Линейный::::خطي::::Linéaire::::::::::::Linear' WHERE code = 'linear';

-- Data for Name: request_display_group; Type: TABLE DATA; Schema: application; Owner: postgres
--

UPDATE application.request_display_group SET status = 'x' WHERE code IN ('systematicReg', 'gender', 'survey');


-- Data for Name: application.request_type; Type: TABLE DATA; Schema: application; Owner: postgres
--
UPDATE application.request_type SET status = 'x' WHERE code IN( 'regnDeeds', 'newDigitalProperty', 'newState', 'documentCopy', 'newApartment', 'obscurationRequest', 'recordRelationship', 'regnStandardDocument', 
'lifeEstate', 'usufruct', 'waterRights', 'noteOccupation', 'recordTransfer', 'cadastreBulk', 'cadastreExport','surveyPlanCopy', 'lodgeObjection', 'mapExistingParcel', 'systematicRegn', 'historicOrder', 
'limitedRoadAccess', 'servitude', 'cadastreChange', 'cadastrePrint', 'redefineCadastre', 'buildingRestriction', 'cancelRelationship', 'cnclStandardDocument');


UPDATE application.request_type SET display_value = 'Other CofO Registration::::Регистрация права собственности::::التسجيل على سند ملكية::::Enregistrement du Titre::::::::Registro no Título::::产权登记' WHERE code = 'regnOnTitle';
UPDATE application.request_type SET display_value = 'Cancel CofO::::Прекращение права собственности::::الغاء سند ملكية::::Annuler Titre::::::::Título Cancelado::::取消产权' WHERE  code = 'cancelProperty';
UPDATE application.request_type SET display_value =  'Register Sub-lease::::Регистрация права пользования::::تسجيل ايجار::::Enregistrer Bail::::::::Cadastrar Arrendamento::::登记租赁' WHERE code = 'registerLeased';
UPDATE application.request_type SET display_value =  'Vary Sub-lease::::Изменить право пользования::::تعديل الايجار::::Varier Bail::::::::Variar Arrendamento::::变更租赁' WHERE code = 'varyLease';
UPDATE application.request_type SET display_value =  'Existing Boundaries Change::::Изменение кадастрового объекта::::إعادة تعريف المساحة::::Redéfinir Cadastre::::::::Redefinir o Cadastro::::重新定义地籍' WHERE code = 'redefineCadastre';
UPDATE application.request_type SET display_value =  'New CofO::::Новое право собственности (свободное)::::سند ملكية جديد::::Nouveau Titre Propriété::::::::Novo Título de Propriedade::::新的终身保有产权' WHERE code = 'newFreehold';
UPDATE application.request_type SET display_value =  'Assign and Devolve::::Смена владельца::::تغيير الملكية::::Changement de propriétaire::::::::Mudança de Propriedade::::所有权变更' WHERE code = 'newOwnership';
UPDATE application.request_type SET display_value =  'Subdivide CofO::::???????? ????? (?????)::::????? ?? (???)::::Varier Droit (Gê¯©ral)::::::::Variar Direitos (Geral)::::???? (??)' WHERE code = 'subdivideProperty';
UPDATE application.request_type SET display_value =  'CofO Search::::Поиск недвижимости::::البحث عن سند ملكية.::::Recherche Titre::::::::Buscar o Título::::产权调查' WHERE code = 'titleSearch';


-- Data for Name: rrr_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

UPDATE administrative.rrr_type SET status = 'x' WHERE code IN ('tenancy', 'ownershipAssumed', 'customaryType', 'commonOwnership', 'waterwayMaintenance', 'agriActivity', 'grazing', 'monumentMaintenance', 'monument', 'superficies', 'informalOccupation', 'lifeEstate',
'adminPublicServitude', 'firewood', 'fishing', 'apartment', 'noBuilding', 'occupation', 'servitude', 'usufruct', 'waterrights', 'historicPreservation', 'limitedAccess', 'stateOwnership');

UPDATE administrative.rrr_type SET display_value = 'Sub-lease::::Аренда::::الأيجار::::Bail::::Arrendamiento::::Arrendamento::::租赁' WHERE code = 'lease';
UPDATE administrative.rrr_type SET display_value = 'Statutory Right of Occupation::::Право собственности::::ملكية::::Propriété::::Propiedad::::Proprietário::::所有权' WHERE code = 'ownership';

