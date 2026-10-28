--liquibase formatted sql

--changeset adetola:100-01 endDelimiter:/ rollbackSplitStatements:false
--comment: Hourly job: lock visits 24 hours after completion (FR-CLN-04)
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JM_LOCK_COMPLETED_VISITS',
        job_type        => 'PLSQL_BLOCK',
        job_action      => q'[BEGIN
                                UPDATE jm_visits
                                   SET status = 'LOCKED',
                                       locked_at = SYSTIMESTAMP
                                 WHERE status = 'COMPLETED'
                                   AND completed_at < SYSTIMESTAMP - INTERVAL '1' DAY;
                                COMMIT;
                              END;]',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=HOURLY;BYMINUTE=5',
        enabled         => TRUE,
        comments        => 'JanastolMeds: lock completed visits after 24 hours (FR-CLN-04)');
END;
/
--rollback BEGIN DBMS_SCHEDULER.DROP_JOB('JM_LOCK_COMPLETED_VISITS'); END;

-- The nightly audit-chain verification job is added with JM_SECURITY_API in the packages phase.
