INSERT INTO warehouse.tags_jobs_fact (
    tag_id, 
    job_id, 
    job_title_id, 
    seniority_id, 
    updated_at
)
SELECT
    t.tag_id,
    g.job_id,
    ti.title_id,
    se.seniority_id,
    CURRENT_TIMESTAMP AS updated_at
FROM 
    (
    SELECT 
        g.job_id,
        g.source_job_id,
        g.description_tokens
    FROM 
        warehouse.jobs_dim g
    LEFT JOIN
        warehouse.tags_jobs_fact d 
    ON 
        g.job_id = d.job_id 
    WHERE
        d.job_id IS NULL
        AND g.source_job_id IS NOT NULL
) as g
LEFT JOIN 
    staging.gsearch_jobs sg
    ON g.source_job_id = sg.source_job_id
LEFT JOIN 
    warehouse.tags_dim t 
    ON t.tag = ANY(g.description_tokens)
LEFT JOIN 
    warehouse.titles ti 
    ON ti.title = sg.cleaned_title
JOIN 
    warehouse.seniority se 
    ON se.seniority = sg.cleaned_seniority 
WHERE
	t.tag_id IS NOT NULL; 
