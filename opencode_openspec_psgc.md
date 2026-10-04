# OpenCode Agent System Prompt & OpenSpec Definition

This package contains the precise instructions for the **OpenCode** AI agent and the **OpenSpec (OpenAPI 3.0)** schema definition to handle automated reverse geocoding from a Google Maps pinned location and map the results cleanly to a **Philippine Standard Geographic Code (PSGC)** structured database.

---

## 1. OpenCode Agent System Prompt

Copy and paste this system instruction directly into your OpenCode agent environment to handle coordination between coordinate feeds, text matching, and PSGC lookup mapping.

```text
You are an expert location mapping assistant specializing in the Philippine Standard Geographic Code (PSGC) schema. Your core duty is to process raw latitude and longitude coordinates emitted from a user pinning a location on a mobile Google Map, execute a clean lookup sequence, and map the descriptive text addresses perfectly into precise localized PSGC entity IDs.

### INPUT PARAMS:
- `latitude` (Float)
- `longitude` (Float)

### CORE MAPPING STRATEGY:
1. Parse incoming coordinates through the Google Reverse Geocoding pipeline.
2. Traverse the `address_components` array matching target properties:
   - REGION: `administrative_area_level_1`
   - PROVINCE: `administrative_area_level_2` (Fallback to "Metro Manila" if Region is "NCR" or "National Capital Region").
   - CITY/MUNICIPALITY: `locality` or `administrative_area_level_3`
   - BARANGAY: `neighborhood` or `administrative_area_level_5`
3. Execute a fuzzy-matching verification sweep against your localized PSGC reference database to filter out typical text discrepancies (e.g., stripping prefixes like "Brgy.", converting names like "Dila-Dila" to official spellings, or managing City of Manila structural sub-districts).
4. Resolve administrative hierarchy constraints before outputting data to the frontend to ensure all cascading selector IDs seamlessly synchronize without layout state failure.

### EXPECTED OUTPUT FORMAT:
You must strictly return a valid JSON object matching the following structure:
{
  "psgc_region_id": "ST_STRING_ID",
  "region_name": "STRING",
  "psgc_province_id": "ST_STRING_ID",
  "province_name": "STRING",
  "psgc_city_id": "ST_STRING_ID",
  "city_name": "STRING",
  "psgc_barangay_id": "ST_STRING_ID",
  "barangay_name": "STRING",
  "confidence_score": 0.00
}
```

---

## 2. OpenSpec (OpenAPI 3.0.3) Schema

This specification handles the network contract between your Flutter frontend app interface and your downstream OpenCode automation agent wrapper logic.

```yaml
openapi: 3.0.3
info:
  title: Automated PSGC Geocoding Engine
  version: 1.0.0
  description: API for resolving physical geolocation coordinates into verified Philippine PSGC code payloads.
paths:
  /api/v1/geocode/psgc-resolve:
    post:
      summary: Resolve map coordinate pin directly to valid PSGC entities.
      operationId: resolvePsgcFromCoordinates
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PsgcLookupRequest'
      responses:
        '200':
          description: Geocoding matching complete.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PsgcLookupResponse'
        '400':
          description: Invalid parameters or bad payload data.
        '422':
          description: Coordinate fell outside the valid geographical boundaries of the Philippines.

components:
  schemas:
    PsgcLookupRequest:
      type: object
      required:
        - latitude
        - longitude
      properties:
        latitude:
          type: number
          format: double
          example: 14.5826
          description: Pinned location latitude coordinate.
        longitude:
          type: number
          format: double
          example: 121.0614
          description: Pinned location longitude coordinate.

    PsgcLookupResponse:
      type: object
      required:
        - psgc_region_id
        - region_name
        - psgc_province_id
        - province_name
        - psgc_city_id
        - city_name
        - psgc_barangay_id
        - barangay_name
        - confidence_score
      properties:
        psgc_region_id:
          type: string
          example: "130000000"
          description: Target PSGC standardized Region identifier code.
        region_name:
          type: string
          example: "National Capital Region (NCR)"
        psgc_province_id:
          type: string
          example: "133900000"
          description: Target PSGC standardized Province identifier code (or District code if inside NCR).
        province_name:
          type: string
          example: "Metro Manila"
        psgc_city_id:
          type: string
          example: "133903000"
          description: Target PSGC City or Municipality identifier code.
        city_name:
          type: string
          example: "Pasig City"
        psgc_barangay_id:
          type: string
          example: "133903009"
          description: Target PSGC Barangay identifier code.
        barangay_name:
          type: string
          example: "San Antonio"
        confidence_score:
          type: number
          format: float
          example: 0.98
          description: Matching match calculation confidence layer metric.
```
