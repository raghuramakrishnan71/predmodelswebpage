#standardSQL
# 01: Create list of URLs.
# Store in httparchiveext.plt2.20170315_urls.
SELECT 
  rank, 
  url 
FROM 
  `httparchive.summary_pages.2017_03_15_desktop`
WHERE
  rank <= 20000 AND
  reqAudio = 0 AND
  reqVideo = 0 AND
  bytesAudio = 0 AND
  bytesVideo = 0
ORDER BY rank


#standardSQL
# 02: Percentage of websites by categories.
SELECT 
  category,
  COUNT(category) AS freq,
  SUM(COUNT(0)) OVER() AS total,
  ROUND(COUNT(category) * 100/ SUM(COUNT(0)) OVER(), 2) AS pct
FROM 
  `httparchiveext.plt2.20170315_urls`
GROUP BY
  category
ORDER BY
  freq DESC


#standardSQL
# 03: Percentage of select 10 categories.
SELECT 
  COUNTIF(category IN ('Information Technology', 'News and Media', 'Business', 'Shopping', 'Education', 'Entertainment', 'Finance and Banking', 'Search Engines and Portals', 'Travel', 'Government and Legal Organizations')) AS cnt,
  COUNT(category) AS total,
  ROUND(COUNTIF(category IN ('Information Technology', 'News and Media', 'Business', 'Shopping', 'Education', 'Entertainment', 'Finance and Banking', 'Search Engines and Portals', 'Travel', 'Government and Legal Organizations')) * 100/ COUNT(category), 2) AS pct
FROM 
  `httparchiveext.plt2.20170315_urls`

#standardSQL
# 04: Create list of URLs of select 10 categories.
# Store in httparchiveext.plt2.20170315_urls_10.
SELECT
  url,
  category
FROM
  `httparchiveext.plt2.20170315_urls`
WHERE
   category IN ('Information Technology', 'News and Media', 'Business', 'Shopping', 'Education', 'Entertainment', 'Finance and Banking', 'Search Engines and Portals', 'Travel', 'Government and Legal Organizations') 


#standardSQL
# 05: Count number of URLs of select 10 categories.
SELECT 
  COUNT(category)
FROM
  `httparchiveext.plt2.20170315_urls_10`

#standardSQL
# 06a: Fetch attributes. Store in pages_10_part1, 292807 records.
SELECT
  SUBSTR(_TABLE_SUFFIX, 0, 10) AS date,
  url,
  pageid, onLoad, fullyLoaded, renderStart, onContentLoaded, TTFB, visualComplete, SpeedIndex, rank,
  reqTotal, reqHtml, reqJS, reqCSS, reqImg,
  reqGif, reqJpg, reqPng, reqFont, reqFlash, reqJson, reqOther,
  reqText, reqXml, reqWebp, reqSvg, reqAudio, reqVideo,
  bytesTotal, bytesHtml, bytesJS, bytesCSS, bytesImg,
  bytesGif, bytesJpg, bytesPng, bytesFont, bytesFlash, bytesJson, bytesOther,
  bytesHtmlDoc, bytesText, bytesXml, bytesWebp, bytesSvg, bytesAudio, bytesVideo,
  numDomains, maxDomainReqs, numRedirects, numDomElements,
  _connections, avg_dom_depth, num_iframes, num_scripts_async, num_scripts_sync
FROM
  `httparchive.summary_pages.*`
WHERE
  _TABLE_SUFFIX >= '2017_03_15'               
  AND _TABLE_SUFFIX <= '2018_06_15' 
  AND ENDS_WITH(_TABLE_SUFFIX, 'desktop')
  AND url IN (SELECT url from `httparchiveext.plt2.20170315_urls_10`)

#standardSQL
# 06b: Fetch extended attributes. Store in YYYY_MM_DD_part2.
WITH requests AS (
  SELECT pageid, req_host, respSize, _cdn_provider, SUBSTR(REGEXP_EXTRACT(url, r'([:]//[a-z0-9\-._~%]+)'), 4) actual_req_host
  FROM 
  httparchive.summary_requests.2017_02_01_desktop
  WHERE
  pageid IN (
      SELECT pageid FROM httparchiveext.plt2.pages_10_part1
      WHERE date in ('2017_02_01')
      )
  )
SELECT '2017_02_01' AS date2, pages.pageid,
       COUNT(pages.pageid) AS reqTotal2,
       COUNT(DISTINCT(IF (STRPOS(req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, NULL, IF (LENGTH(req_host) > 0, req_host, NULL)))) AS numThirdParty,
       SUM(IF (STRPOS(req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, 0, IF (LENGTH(req_host) > 0, 1, NULL))) AS reqThirdParty,
       SUM(IF (STRPOS(req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, 0, IF (LENGTH(req_host) > 0, respSize, NULL))) AS bytesThirdParty,
       COUNT(DISTINCT(IF (LENGTH(_cdn_provider) > 0, _cdn_provider, NULL) )) AS numCdns,
       SUM(IF (LENGTH(_cdn_provider) > 0, 1, 0) ) AS reqCdn,
       SUM(IF (LENGTH(_cdn_provider) > 0, respSize, 0) ) AS bytesCdn,
       COUNT(DISTINCT(IF (STRPOS(req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, req_host, NULL))) AS numFirstParty,
       SUM(IF (STRPOS(req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, 1, NULL)) AS reqFirstParty,
       SUM(IF (STRPOS(req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, respSize, NULL)) AS bytesFirstParty,
       COUNT(DISTINCT(IF (STRPOS(actual_req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, NULL, IF (LENGTH(actual_req_host) > 0, actual_req_host, NULL)))) AS numThirdParty2,
       SUM(IF (STRPOS(actual_req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, 0, IF (LENGTH(actual_req_host) > 0, 1, NULL))) AS reqThirdParty2,
       SUM(IF (STRPOS(actual_req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, 0, IF (LENGTH(actual_req_host) > 0, respSize, NULL))) AS bytesThirdParty2,
       COUNT(DISTINCT(IF (STRPOS(actual_req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, actual_req_host, NULL))) AS numFirstParty2,
       SUM(IF (STRPOS(actual_req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, 1, NULL)) AS reqFirstParty2,
       SUM(IF (STRPOS(actual_req_host, REGEXP_EXTRACT(origin, r'([\w-]+)')) > 0, respSize, NULL)) AS bytesFirstParty2
FROM requests INNER JOIN (
    SELECT pageid, date, NET.REG_DOMAIN(url) as origin
    FROM  httparchiveext.plt2.pages_10_part1
    WHERE date in ('2017_02_01')
) pages
ON pages.pageid = requests.pageid
GROUP by pages.pageid
ORDER by pages.pageid

#standardSQL
# 06c: Fetch records in YYYY_MM_DD_part2. Store in pages_10_part2.
SELECT 
  date2, pageid, reqTotal2, numThirdParty,	
  reqThirdParty, bytesThirdParty, numCdns, 
  reqCdn, bytesCdn, numFirstParty, reqFirstParty, 
  bytesFirstParty, numThirdParty2, 
  reqThirdParty2, bytesThirdParty2, numFirstParty2, 
  reqFirstParty2, bytesFirstParty2
FROM
   `httparchiveext.plt2.2017_*`
UNION ALL
SELECT 
  date2, pageid, reqTotal2, numThirdParty,	
  reqThirdParty, bytesThirdParty, numCdns, 
  reqCdn, bytesCdn, numFirstParty, reqFirstParty, 
  bytesFirstParty, numThirdParty2, 
  reqThirdParty2, bytesThirdParty2, numFirstParty2, 
  reqFirstParty2, bytesFirstParty2
FROM
   `httparchiveext.plt2.2018_*`

#standardSQL
# 06d: Merge records from pages_10_part1 and pages_10_part2.
# Store in results_10cat_consolidated.
SELECT
  part1part2.date AS date,
  part1part2.url AS url,
  urls.category AS category,
  pageid, onLoad, fullyLoaded, renderStart, onContentLoaded, 
  TTFB, visualComplete, SpeedIndex, rank,
  reqTotal, reqHtml, reqJS, reqCSS, reqImg,
  reqGif, reqJpg, reqPng, reqFont, reqFlash, reqJson, reqOther,
  reqText, reqXml, reqWebp, reqSvg, reqAudio, reqVideo,
  bytesTotal, bytesHtml, bytesJS, bytesCSS, bytesImg,
  bytesGif, bytesJpg, bytesPng, bytesFont, bytesFlash, bytesJson, bytesOther,
  bytesHtmlDoc, bytesText, bytesXml, bytesWebp, bytesSvg, bytesAudio, bytesVideo,
  numDomains, maxDomainReqs, numRedirects, numDomElements,
  _connections, avg_dom_depth, num_scripts_async, num_scripts_sync,
  numThirdParty, reqThirdParty, bytesThirdParty,
  numCdns, reqCdn, bytesCdn,
  numFirstParty, reqFirstParty, bytesFirstParty,
  numThirdParty2, reqThirdParty2, bytesThirdParty2,
  numFirstParty2, reqFirstParty2, bytesFirstParty2
FROM (
  SELECT
    part1.date,
    part1.url,
    part1.pageid, onLoad, fullyLoaded, renderStart, onContentLoaded, 
    TTFB, visualComplete, SpeedIndex, rank,
    reqTotal, reqHtml, reqJS, reqCSS, reqImg,
    reqGif, reqJpg, reqPng, reqFont, reqFlash, reqJson, reqOther,
    reqText, reqXml, reqWebp, reqSvg, reqAudio, reqVideo,
    bytesTotal, bytesHtml, bytesJS, bytesCSS, bytesImg,
    bytesGif, bytesJpg, bytesPng, bytesFont, bytesFlash, bytesJson, bytesOther,
    bytesHtmlDoc, bytesText, bytesXml, bytesWebp, bytesSvg, bytesAudio, bytesVideo,
    numDomains, maxDomainReqs, numRedirects, numDomElements,
    _connections, avg_dom_depth, num_scripts_async, num_scripts_sync,
    numThirdParty, reqThirdParty, bytesThirdParty,
    numCdns, reqCdn, bytesCdn,
    numFirstParty, reqFirstParty, bytesFirstParty,
    numThirdParty2, reqThirdParty2, bytesThirdParty2,
    numFirstParty2, reqFirstParty2, bytesFirstParty2
  FROM
    httparchiveext.plt2.pages_10_part1 part1 INNER JOIN (
      SELECT 
        date2, pageid,
        numThirdParty, reqThirdParty, bytesThirdParty,
        numCdns, reqCdn, bytesCdn,
        numFirstParty, reqFirstParty, bytesFirstParty,
        numThirdParty2, reqThirdParty2, bytesThirdParty2,
        numFirstParty2, reqFirstParty2, bytesFirstParty2
      FROM 
        httparchiveext.plt2.pages_10_part2
    ) part2
  ON
    part1.date = part2.date2 AND
    part1.pageid = part2.pageid
) part1part2
INNER JOIN
  httparchiveext.plt2.20170315_urls_10 urls
ON
  part1part2.url = urls.url 
order by urls.category, part1part2.url

#standardSQL
# 07: Percentile of onload time across categories.
# Store in stats.
(SELECT
  category,
  COUNT(category) AS count,
  ROUND(MIN(onLoad)/1000, 2) AS min_onload,
  ROUND(AVG(onLoad)/1000, 2) AS avg_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)]/1000, 2) AS p50_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(900)]/1000, 2) AS p90_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(950)]/1000, 2) AS p95_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(990)]/1000, 2) AS p99_onload,
  ROUND(MAX(onLoad)/1000, 2) AS max_onload,
  ROUND(MIN(bytesTotal)/1024, 2) AS min_bytestotal,
  ROUND(AVG(bytesTotal)/1024, 2) AS avg_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(500)]/1024, 2) AS p50_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(900)]/1024, 2) AS p90_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(950)]/1024, 2) AS p95_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(990)]/1024, 2) AS p99_bytestotal,
  ROUND(MAX(bytesTotal)/1024, 2) AS max_bytestotal,
  MIN(reqTotal) AS min_reqtotal,
  AVG(reqTotal) AS avg_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(500)] AS p50_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(900)] AS p90_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(950)] AS p95_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(990)] AS p99_reqtotal,
  MAX(reqTotal) AS max_reqtotal
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
   onLoad > 0
   AND reqAudio = 0 
   AND reqVideo = 0 
   AND bytesAudio = 0 
   AND bytesVideo = 0
   AND TTFB < onLoad
   AND reqTotal > 5
   AND bytesTotal > 1024
GROUP BY
  category
ORDER BY
  category
) UNION ALL
(SELECT
  'All',
  COUNT(0) AS count,
  ROUND(MIN(onLoad)/1000, 2) AS min_onload,
  ROUND(AVG(onLoad)/1000, 2) AS avg_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)]/1000, 2) AS p50_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(900)]/1000, 2) AS p90_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(950)]/1000, 2) AS p95_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(990)]/1000, 2) AS p99_onload,
  ROUND(MAX(onLoad)/1000, 2) AS max_onload,
  ROUND(MIN(bytesTotal)/1024, 2) AS min_bytestotal,
  ROUND(AVG(bytesTotal)/1024, 2) AS avg_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(500)]/1024, 2) AS p50_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(900)]/1024, 2) AS p90_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(950)]/1024, 2) AS p95_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(990)]/1024, 2) AS p99_bytestotal,
  ROUND(MAX(bytesTotal)/1024, 2) AS max_bytestotal,
  MIN(reqTotal) AS min_reqtotal,
  AVG(reqTotal) AS avg_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(500)] AS p50_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(900)] AS p90_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(950)] AS p95_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(990)] AS p99_reqtotal,
  MAX(reqTotal) AS max_reqtotal
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
   onLoad > 0
   AND reqAudio = 0 
   AND reqVideo = 0 
   AND bytesAudio = 0 
   AND bytesVideo = 0
   AND TTFB < onLoad
   AND reqTotal > 5
   AND bytesTotal > 1024
)

#standardSQL
# 08a: Select the record with median onLoad time for Information Technology category.
# Store in cat_information_technology.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Information Technology'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
#         AND url IN (SELECT url from httparchiveext.plt2.20170315_urls_10 where category IN ('Information Technology'))
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Information Technology'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024

#standardSQL
# 08b: Select the record with median onLoad time for News and Media category.
# Store in cat_news_and_media.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'News and Media'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'News and Media'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024

#standardSQL
# 08c: Select the record with median onLoad time for Business category.
# Store in cat_business.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Business'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Business'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024

#standardSQL
# 08d: Select the record with median onLoad time for Shopping category.
# Store in cat_shopping.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Shopping'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Shopping'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024


#standardSQL
# 08e: Select the record with median onLoad time for Education category.
# Store in cat_education.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Education'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Education'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024


#standardSQL
# 08f: Select the record with median onLoad time for Entertainment category.
# Store in cat_entertainment.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Entertainment'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Entertainment'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024

#standardSQL
# 08g: Select the record with median onLoad time for Finance and Banking category.
# Store in cat_finance_and_banking.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Finance and Banking'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Finance and Banking'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024


#standardSQL
# 08h: Select the record with median onLoad time for Search Engines and Portals category.
# Store in cat_search_engines_and_portals.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Search Engines and Portals'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Search Engines and Portals'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024


#standardSQL
# 08i: Select the record with median onLoad time for Travel category.
# Store in cat_travel.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Travel'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Travel'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024


# 08j: Select the record with median onLoad time for Government and Legal Organizations category.
# Store in cat_government_and_legal_organizations.
SELECT
  *
FROM
  httparchiveext.plt2.results_10cat_consolidated
WHERE
  CONCAT(url, CAST(onLoad AS STRING)) IN (
    SELECT
      CONCAT(url, CAST(p50_onload AS STRING)) AS url_onload
    FROM
    (
        SELECT
          url,
          APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)] AS p50_onload
        FROM
          httparchiveext.plt2.results_10cat_consolidated
        WHERE
          category = 'Government and Legal Organizations'
          AND onLoad > 0
          AND reqAudio = 0
          AND reqVideo = 0 
          AND bytesAudio = 0 
          AND bytesVideo = 0
          AND TTFB < onLoad
          AND reqTotal > 5
          AND bytesTotal > 1024
        GROUP BY
          url
        HAVING 
          COUNT(url) >= 15
        ORDER BY
          url
      )
    ) 
    AND category = 'Government and Legal Organizations'
    AND onLoad > 0
    AND reqAudio = 0
    AND reqVideo = 0 
    AND bytesAudio = 0 
    AND bytesVideo = 0
    AND TTFB < onLoad
    AND reqTotal > 5
    AND bytesTotal > 1024

#standardSQL
# 08k: Select the record with median onLoad time for all categories.
# Store in cat_all.
SELECT
  *
FROM
  `httparchiveext.plt2.cat_*`


#standardSQL
# 09a: Percentile of onload time across categories.
# Store in stats.
SELECT
  _TABLE_SUFFIX AS category,
  COUNT(url) AS count,
  ROUND(MIN(onLoad)/1000, 2) AS min_onload,
  ROUND(AVG(onLoad)/1000, 2) AS avg_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)]/1000, 2) AS p50_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(900)]/1000, 2) AS p90_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(950)]/1000, 2) AS p95_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(990)]/1000, 2) AS p99_onload,
  ROUND(MAX(onLoad)/1000, 2) AS max_onload,
  ROUND(MIN(bytesTotal)/1024, 2) AS min_bytestotal,
  ROUND(AVG(bytesTotal)/1024, 2) AS avg_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(500)]/1024, 2) AS p50_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(900)]/1024, 2) AS p90_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(950)]/1024, 2) AS p95_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(990)]/1024, 2) AS p99_bytestotal,
  ROUND(MAX(bytesTotal)/1024, 2) AS max_bytestotal,
  MIN(reqTotal) AS min_reqtotal,
  AVG(reqTotal) AS avg_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(500)] AS p50_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(900)] AS p90_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(950)] AS p95_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(990)] AS p99_reqtotal,
  MAX(reqTotal) AS max_reqtotal
FROM
  `httparchiveext.plt2.cat_*`
GROUP BY
  category

#standardSQL
# 09b: Percentile of onload time across categories.
# Store in stats3.
SELECT
  _TABLE_SUFFIX AS category,
  COUNT(DISTINCT url) AS ucnt,
  COUNT(url) AS count,
  ROUND(MIN(onLoad)/1000, 2) AS min_onload,
  ROUND(AVG(onLoad)/1000, 2) AS avg_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(500)]/1000, 2) AS p50_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(900)]/1000, 2) AS p90_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(950)]/1000, 2) AS p95_onload,
  ROUND(APPROX_QUANTILES(onLoad, 1000)[OFFSET(990)]/1000, 2) AS p99_onload,
  ROUND(MAX(onLoad)/1000, 2) AS max_onload,
  ROUND(MIN(bytesTotal)/1024, 2) AS min_bytestotal,
  ROUND(AVG(bytesTotal)/1024, 2) AS avg_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(500)]/1024, 2) AS p50_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(750)]/1024, 2) AS p75_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(800)]/1024, 2) AS p80_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(900)]/1024, 2) AS p90_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(950)]/1024, 2) AS p95_bytestotal,
  ROUND(APPROX_QUANTILES(bytesTotal, 1000)[OFFSET(990)]/1024, 2) AS p99_bytestotal,
  ROUND(MAX(bytesTotal)/1024, 2) AS max_bytestotal,
  ROUND(MIN(bytesJS)/1024, 2) AS min_bytesjs,
  ROUND(AVG(bytesJS)/1024, 2) AS avg_bytesjs,
  ROUND(APPROX_QUANTILES(bytesJS, 1000)[OFFSET(500)]/1024, 2) AS p50_bytesjs,
  ROUND(APPROX_QUANTILES(bytesJS, 1000)[OFFSET(900)]/1024, 2) AS p90_bytesjs,
  ROUND(APPROX_QUANTILES(bytesJS, 1000)[OFFSET(950)]/1024, 2) AS p95_bytesjs,
  ROUND(APPROX_QUANTILES(bytesJS, 1000)[OFFSET(990)]/1024, 2) AS p99_bytesjs,
  ROUND(MAX(bytesJS)/1024, 2) AS max_bytesjs,
  ROUND(MIN(bytesCSS)/1024, 2) AS min_bytescss,
  ROUND(AVG(bytesCSS)/1024, 2) AS avg_bytescss,
  ROUND(APPROX_QUANTILES(bytesCSS, 1000)[OFFSET(500)]/1024, 2) AS p50_bytescss,
  ROUND(APPROX_QUANTILES(bytesCSS, 1000)[OFFSET(900)]/1024, 2) AS p90_bytescss,
  ROUND(APPROX_QUANTILES(bytesCSS, 1000)[OFFSET(950)]/1024, 2) AS p95_bytescss,
  ROUND(APPROX_QUANTILES(bytesCSS, 1000)[OFFSET(990)]/1024, 2) AS p99_bytescss,
  ROUND(MAX(bytesCSS)/1024, 2) AS max_bytescss,
  ROUND(MIN(bytesImg)/1024, 2) AS min_bytesimg,
  ROUND(AVG(bytesImg)/1024, 2) AS avg_bytesimg,
  ROUND(APPROX_QUANTILES(bytesImg, 1000)[OFFSET(500)]/1024, 2) AS p50_bytesimg,
  ROUND(APPROX_QUANTILES(bytesImg, 1000)[OFFSET(900)]/1024, 2) AS p90_bytesimg,
  ROUND(APPROX_QUANTILES(bytesImg, 1000)[OFFSET(950)]/1024, 2) AS p95_bytesimg,
  ROUND(APPROX_QUANTILES(bytesImg, 1000)[OFFSET(990)]/1024, 2) AS p99_bytesimg,
  ROUND(MAX(bytesImg)/1024, 2) AS max_bytesimg,
  ROUND(APPROX_QUANTILES(bytesJs/bytesTotal, 1000)[OFFSET(500)], 2) AS p50_bytesjscontri,
  ROUND(APPROX_QUANTILES(bytesJs/bytesTotal, 1000)[OFFSET(900)], 2) AS p90_bytesjscontri,
  ROUND(APPROX_QUANTILES(bytesCss/bytesTotal, 1000)[OFFSET(500)], 2) AS p50_bytescsscontri,
  ROUND(APPROX_QUANTILES(bytesCss/bytesTotal, 1000)[OFFSET(900)], 2) AS p90_bytescsscontri,
  ROUND(APPROX_QUANTILES(bytesImg/bytesTotal, 1000)[OFFSET(500)], 2) AS p50_bytesimgcontri,
  ROUND(APPROX_QUANTILES(bytesImg/bytesTotal, 1000)[OFFSET(900)], 2) AS p90_bytesimgcontri,
  MIN(reqTotal) AS min_reqtotal,
  AVG(reqTotal) AS avg_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(500)] AS p50_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(750)] AS p75_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(800)] AS p80_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(900)] AS p90_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(950)] AS p95_reqtotal,
  APPROX_QUANTILES(reqTotal, 1000)[OFFSET(990)] AS p99_reqtotal,
  MAX(reqTotal) AS max_reqtotal,
  MIN(reqJS) AS min_reqjs,
  AVG(reqJS) AS avg_reqjs,
  APPROX_QUANTILES(reqJS, 1000)[OFFSET(500)] AS p50_reqjs,
  APPROX_QUANTILES(reqJS, 1000)[OFFSET(900)] AS p90_reqjs,
  APPROX_QUANTILES(reqJS, 1000)[OFFSET(950)] AS p95_reqjs,
  APPROX_QUANTILES(reqJS, 1000)[OFFSET(990)] AS p99_reqjs,
  MAX(reqJS) AS max_reqjs,
  MIN(reqCSS) AS min_reqcss,
  AVG(reqCSS) AS avg_reqcss,
  APPROX_QUANTILES(reqCSS, 1000)[OFFSET(500)] AS p50_reqcss,
  APPROX_QUANTILES(reqCSS, 1000)[OFFSET(900)] AS p90_reqcss,
  APPROX_QUANTILES(reqCSS, 1000)[OFFSET(950)] AS p95_reqcss,
  APPROX_QUANTILES(reqCSS, 1000)[OFFSET(990)] AS p99_reqcss,
  MAX(reqCSS) AS max_reqcss,
  MIN(reqImg) AS min_reqimg,
  AVG(reqImg) AS avg_reqimg,
  APPROX_QUANTILES(reqImg, 1000)[OFFSET(500)] AS p50_reqimg,
  APPROX_QUANTILES(reqImg, 1000)[OFFSET(900)] AS p90_reqimg,
  APPROX_QUANTILES(reqImg, 1000)[OFFSET(950)] AS p95_reqimg,
  APPROX_QUANTILES(reqImg, 1000)[OFFSET(990)] AS p99_reqimg,
  MAX(reqImg) AS max_reqimg,
  APPROX_QUANTILES(ROUND(reqJS/reqTotal, 2), 1000)[OFFSET(500)] AS p50_reqjscontri,
  APPROX_QUANTILES(ROUND(reqJS/reqTotal, 2), 1000)[OFFSET(900)] AS p90_reqjscontri,
  APPROX_QUANTILES(ROUND(reqCSS/reqTotal, 2), 1000)[OFFSET(500)] AS p50_reqcsscontri,
  APPROX_QUANTILES(ROUND(reqCSS/reqTotal, 2), 1000)[OFFSET(900)] AS p90_reqcsscontri,
  APPROX_QUANTILES(ROUND(reqImg/reqTotal, 2), 1000)[OFFSET(500)] AS p50_reqimgcontri,
  APPROX_QUANTILES(ROUND(reqImg/reqTotal, 2), 1000)[OFFSET(900)] AS p90_reqimgcontri
FROM
  `httparchiveext.plt2.dataset_*`
GROUP BY
  category

#standardSQL
# 09c: Descriptive stats on load time and content complexity.
SELECT
  category,
  ucnt,
  count,
  min_onload,
  avg_onload,
  p50_onload,
  p90_onload,
  p95_onload,
  p99_onload,
  max_onload,
  p50_bytestotal,
  p75_bytestotal,
  p80_bytestotal,
  p90_bytestotal,
  p50_bytesjs,
  p50_bytescss,
  p50_bytesimg,
  p50_bytesjscontri,
  p50_bytescsscontri,
  p50_bytesimgcontri,
  p50_reqtotal,
  p75_reqtotal,
  p80_reqtotal,
  p90_reqtotal,
  p50_reqjs,
  p50_reqcss,
  p50_reqimg,
  p50_reqjscontri,
  p50_reqcsscontri,
  p50_reqimgcontri  
FROM
  `httparchiveext.plt2.stats3`
ORDER BY
  category

#standardSQL
# 09d: Percentile of service complexity metrics across categories.
SELECT
  _TABLE_SUFFIX AS category,
  APPROX_QUANTILES(reqThirdParty2, 1000)[OFFSET(500)] AS p50_reqthirdparty2,
  APPROX_QUANTILES(reqThirdParty2, 1000)[OFFSET(900)] AS p90_reqthirdparty2,
  ROUND(APPROX_QUANTILES(bytesthirdparty2, 1000)[OFFSET(500)]/1024, 2) AS p50_bytesthirdparty2,
  ROUND(APPROX_QUANTILES(bytesthirdparty2, 1000)[OFFSET(900)]/1024, 2) AS p90_bytesthirdparty2,
  ROUND(COUNTIF(reqThirdParty2 > 1)/COUNT(0), 2) AS thirdparty_gt_1,
  ROUND(COUNTIF(reqCdn > 1)/COUNT(0), 2) AS cdn_gt_1
FROM
  `httparchiveext.plt2.dataset_*`
GROUP BY
  category

#standardSQL
# 09e: Overall percentage of third party.
SELECT
  _TABLE_SUFFIX AS category,
  ROUND(COUNTIF(reqThirdParty2 > 1)/COUNT(0), 2) AS thirdparty_gt_1,
  ROUND(COUNTIF(reqCdn > 1)/COUNT(0), 2) AS cdn_gt_1,  
  ROUND(SUM(reqThirdParty2)/SUM(reqTotal), 2) AS total_reqthirdparty2,
  ROUND(SUM(reqFirstParty2)/SUM(reqTotal), 2) AS total_reqfirstparty2,
  ROUND(SUM(bytesThirdParty2)/SUM(bytesTotal), 2) AS total_bytesthirdparty2,
  ROUND(SUM(bytesFirstParty2)/SUM(bytesTotal), 2) AS total_bytesfirstparty2,
  ROUND(SUM(reqCdn)/SUM(reqTotal), 2) AS total_reqcdn,
  ROUND(SUM(bytesCdn)/SUM(bytesTotal), 2) AS total_bytesCdn
FROM
  `httparchiveext.plt2.dataset_*`
GROUP BY
  category

#standardSQL
# 10: Correlation coefficients of various attributes with onload (Information Technology).
SELECT "onLoad" Metric,
  ROUND(CORR(onLoad, TTFB), 2) ttfb,
  ROUND(CORR(onLoad, reqTotal), 2) requests,
  ROUND(CORR(onLoad, reqJS), 2) js_requests,
  ROUND(CORR(onLoad, reqCSS), 2) css_requests,
  ROUND(CORR(onLoad, reqImg), 2) image_requests,
  ROUND(CORR(onLoad, reqNonJsCsImg), 2) nonjscsimg_requests,
  ROUND(CORR(onLoad, bytesTotal), 2) bytes,
  ROUND(CORR(onLoad, bytesJS), 2) js_bytes,
  ROUND(CORR(onLoad, bytesCSS), 2) css_bytes,
  ROUND(CORR(onLoad, bytesImg), 2) img_bytes,
  ROUND(CORR(onLoad, reqNonJsCsImg), 2) nonjscsimg_bytes,
  ROUND(CORR(onLoad, numDomains), 2) domains,
  ROUND(CORR(onLoad, maxDomainReqs), 2) max_domain_reqs,
  ROUND(CORR(onLoad, numRedirects), 2) num_redirects,
  ROUND(CORR(onLoad, numDomElements), 2) num_dom_elements,
  ROUND(CORR(onLoad, _connections), 2) connections,
  ROUND(CORR(onLoad, avg_dom_depth), 2) avgg_dom_depth,
  ROUND(CORR(onLoad, (num_scripts_sync + num_scripts_async)), 2) scripts,
  ROUND(CORR(onLoad, num_scripts_sync), 2) sync_scripts,
  ROUND(CORR(onLoad, num_scripts_async), 2) async_scripts,
  ROUND(CORR(onLoad, numCdns), 2) num_cdns,
  ROUND(CORR(onLoad, reqCdn), 2) req_cdn,
  ROUND(CORR(onLoad, bytesCdn), 2) bytes_cdn,
  ROUND(CORR(onLoad, numThirdParty2), 2) num_third_party,
  ROUND(CORR(onLoad, reqThirdParty2), 2) req_third_party,
  ROUND(CORR(onLoad, bytesThirdParty2), 2) bytes_third_party,
  ROUND(CORR(onLoad, numFirstParty2), 2) num_first_party,
  ROUND(CORR(onLoad, reqFirstParty2), 2) req_first_party,
  ROUND(CORR(onLoad, bytesFirstParty2), 2) bytes_first_party
FROM
  httparchiveext.plt2.dataset_information_technology

#standardSQL
# 11a: Percentage of occurence during the test crawls.
SELECT
   COUNT(url) AS freq,
   ROUND(COUNT(url) * 100/ 29, 2) AS pct
FROM
   httparchiveext.plt2.results_10cat_consolidated
WHERE
   url IN (SELECT url FROM httparchiveext.plt2.cat_all)
GROUP BY
   url

#standardSQL
# 11b: Date wise count of crawls.
SELECT
   COUNT(date) AS freq
FROM
   httparchiveext.plt2.results_10cat_consolidated
GROUP BY
   date
ORDER BY
   date

#standardSQL
# 12a: Two more derived attributes for Information Technology.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_information_technology
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'information_technology')


#standardSQL
# 12b: Two more derived attributes for News and Media.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_news_and_media
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'news_and_media')

#standardSQL
# 12c: Two more derived attributes for Business.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_business
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'business')

#standardSQL
# 12d: Two more derived attributes for Shopping.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_shopping
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'shopping')

#standardSQL
# 12e: Two more derived attributes for Education.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_education
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'education')

#standardSQL
# 12f: Two more derived attributes for Entertainment.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_entertainment
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'entertainment')

#standardSQL
# 12g: Two more derived attributes for Finance and Banking.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_finance_and_banking
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'finance_and_banking')

#standardSQL
# 12h: Two more derived attributes for Search Engines and Portals.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_search_engines_and_portals
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'search_engines_and_portals')

#standardSQL
# 12i: Two more derived attributes for Travel.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_travel
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'travel')

#standardSQL
# 12j: Two more derived attributes for Government and Legal Organizations.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_government_and_legal_organizations
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'government_and_legal_organizations')

#standardSQL
# 12k: Two more derived attributes for All.
SELECT
  *,
  (reqTotal - (reqJS + reqCSS + reqImg)) AS reqNonJsCsImg,
  (bytesTotal - (bytesJS + bytesCSS + bytesImg)) AS bytesNonJsCsImg
FROM
  httparchiveext.plt2.cat_all
WHERE
  ROUND(onLoad/1000, 2) <= (SELECT p90_onload FROM httparchiveext.plt2.stats WHERE category = 'all')

#standardSQL 
# 13: Calculate r and RMSE for baseline 2.
SELECT
  _TABLE_SUFFIX AS category,
  ROUND(SQRT(SUM(POW(((onLoad - ROUND((bytesTotal * 8 * 1000)/(5.0 * 1024 * 1024), 0))/1000), 2))/COUNT(onLoad)), 2) AS rmse,
  ROUND(CORR(onLoad, ROUND((bytesTotal * 8 * 1000)/(5.0 * 1024 * 1024), 0)), 2) AS r
FROM
  `httparchiveext.plt2.dataset_*`
GROUP BY
  category

#standardSQL
# 14: Calculate r and RMSE for baseline 3.
SELECT
  _TABLE_SUFFIX AS category,
  ROUND(SQRT(SUM(POW(((onLoad - ROUND((ttfb + 100 * (reqTotal - 1) + ((bytesTotal * 8 * 1000)/(5.0 * 1024 * 1024))) * 0.267, 0))/1000), 2))/COUNT(onLoad)), 2) AS rmse,
  ROUND(CORR(onLoad, ROUND((ttfb + 100 * (reqTotal - 1) + ((bytesTotal * 8 * 1000)/(5.0 * 1024 * 1024))) * 0.267, 0)), 2) AS r
FROM
  `httparchiveext.plt2.dataset_*`
GROUP BY
  category


#standardSQL
# 15: Distribution of ttfb.
SELECT
  _TABLE_SUFFIX AS category,
  ROUND(COUNTIF(ttfb < 200)/COUNT(ttfb), 2) AS fast,
  ROUND(COUNTIF(ttfb >= 200 AND ttfb < 1000)/COUNT(ttfb), 2) AS avg,
  ROUND(COUNTIF(ttfb >= 1000)/COUNT(ttfb), 2) AS slow
FROM
  `httparchiveext.plt2.dataset_*`
GROUP BY
  category

#standardSQL
# 16: Distribution of ttfb and backend to frontend ratio.
SELECT
  _TABLE_SUFFIX AS category,
  ROUND(COUNTIF(ttfb < 200)/COUNT(ttfb), 2) AS fast,
  ROUND(COUNTIF(ttfb >= 200 AND ttfb < 1000)/COUNT(ttfb), 2) AS avg,
  ROUND(COUNTIF(ttfb >= 1000)/COUNT(ttfb), 2) AS slow,
  APPROX_QUANTILES(ROUND(ttfb/onLoad, 2), 1000)[OFFSET(500)] AS p50_beferatio,
  APPROX_QUANTILES(ROUND(ttfb/onLoad, 2), 1000)[OFFSET(900)] AS p90_beferatio,
  ROUND(SUM(ttfb)/SUM(onLoad), 2) AS overall_beferatio
FROM
  `httparchiveext.plt2.dataset_*`
GROUP BY
  category