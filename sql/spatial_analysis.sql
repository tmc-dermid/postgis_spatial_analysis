-- =====================================================
-- PostGIS Spatial Analysis
-- File: 01_spatial_analysis.sql
-- Description: Core spatial queries using PostGIS
-- =====================================================

-- =====================================================
-- Tables used in this project (only relevant columns)
-- =====================================================

-- countries
-- - country_id (PK)
-- - country_name

-- country_shapes
-- - shape_id (PK)
-- - country_id (FK)
-- - geom (geometry)


-- 1. Countries neighboring Poland and their area
SELECT
  cs2.country_id,
  c.country_name,
  ROUND(
    (
      ST_Area(cs2.geom::geography) / 1000000
    )::numeric,
    2
  ) AS area_km2
FROM country_shapes cs1
JOIN country_shapes cs2
  ON ST_Intersects(cs1.geom, cs2.geom)
  AND cs1.country_id <> cs2.country_id
JOIN countries c
  ON cs2.country_id = c.country_id
JOIN countries p
  ON cs1.country_id = p.country_id
WHERE p.country_name = 'Poland'
ORDER BY area_km2 DESC; 

-- 2. Distance between Poland and other countries (centroid-based)
SELECT
  c1.country_name || ' <--> ' || c2.country_name AS countries,
  ROUND(
    (
      ST_Distance(
        ST_Centroid(cs1.geom):: geography, 
        ST_Centroid(cs2.geom):: geography
      ) / 1000
    ):: numeric, 
    2
  ) AS distance_km
FROM country_shapes cs1
JOIN country_shapes cs2
  ON cs2.country_id <> cs1.country_id
JOIN countries c1
  ON cs1.country_id = c1.country_id
JOIN countries c2
  ON cs2.country_id = c2.country_id
WHERE c1.country_name = 'Poland'
ORDER BY distance_km DESC;

-- 3. Countries within 1000 km of Poland and their distance
SELECT DISTINCT
  c2.country_id,
  c2.country_name,
  ROUND(
    (
      ST_Distance(
        cs1.geom::geography,
        cs2.geom::geography
      ) / 1000
    )::numeric,
    2
  ) AS distance_km
FROM country_shapes cs1
JOIN countries c1
  ON c1.country_id = cs1.country_id
JOIN country_shapes cs2
  ON cs1.country_id <> cs2.country_id
JOIN countries c2
  ON c2.country_id = cs2.country_id
WHERE c1.country_name = 'Poland'
  AND ST_DWithin(
        cs1.geom::geography,
        cs2.geom::geography,
        1000000
      )
ORDER BY distance_km DESC;
