BEGIN TRANSACTION DeleteStream
        DECLARE @streamIdInternal AS INT;
        DECLARE @latestStreamVersion  AS INT;

         SELECT @streamIdInternal = dbo.Streams.IdInternal
           FROM dbo.Streams
          WHERE dbo.Streams.Id = @streamId;

          IF @streamIdInternal IS NULL
          BEGIN
             RAISERROR('WrongExpectedVersion', 16,1);
             RETURN;
          END

          SELECT TOP(1)
                @latestStreamVersion = dbo.Events.StreamVersion
           FROM dbo.Events
          WHERE dbo.Events.StreamIDInternal = @streamIdInternal
       ORDER BY dbo.Events.Ordinal DESC;

         IF @latestStreamVersion != @expectedStreamVersion
         BEGIN
            RAISERROR('WrongExpectedVersion', 16,2);
            RETURN;
         END

         DELETE FROM dbo.Events
          WHERE dbo.Events.StreamIdInternal = @streamIdInternal;

         DELETE FROM dbo.Streams
          WHERE dbo.Streams.Id = @streamId;

COMMIT TRANSACTION DeleteStream