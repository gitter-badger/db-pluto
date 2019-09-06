DROP TABLE IF EXISTS zola_export;
SELECT bbl, mandatory_inclusionary_housing_flag, inclusionary_housing_flag, transitzones_flag, 
waterfront_access_plan_flag, coastal_zone_boundary_flag, lower_density_growth_management_areas_flag, 
upland_waterfront_areas_flag, appendixj_designated_mdistricts_flag,fresh_zones_flag
INTO zola_export 
FROM pluto_zola;

\COPY (SELECT * FROM pluto) TO 'output/pluto.csv' DELIMITER ',' CSV HEADER;

\COPY (SELECT * FROM zola_export) TO 'output/pluto_zola.csv' DELIMITER ',' CSV HEADER;