# firefoxos-profile-bat

Backup and restore your Firefox OS profile (contacts, SMS, Wi-Fi, settings and apps).

### Usage:

```
profile.bat <backup|restore> [backup_name]
```

By default ```[backup_name]``` folder will be named as current date in ```DD-MM-YYYY_HH-MM-SS``` format. All backups will be stored in local ```/backup``` directory, but you can freely change ```BackupRoot``` and ```BackupPath``` path keys.

### Make a backup:

```
> profile.bat backup my_named_backup

Backup profile...
Creating "my_named_backup" backup...

List of devices attached
36fec263        device

+ Stop b2g...
+ Backup Wi-Fi config...
+ Backup user profile folder...
+ Backup user local data...
+ Start b2g...
+ Backup done!

Check D:\Backup\Flame\my_named_backup\backup-log.txt for details.
```

### Restore from backup:

```
> profile.bat restore my_named_backup

Restore profile...
Do you really want restore "my_named_backup" backup? (Y/N) Y

List of devices attached
36fec263        device

+ Stop b2g...
+ Remove old user profile...
+ Restore Wi-Fi config...
+ Restore user profile...
+ Restore user local data...
+ Start b2g...
+ Restore done!

Check D:\Backup\Flame\my_named_backup\restore-log.txt for details.
```

### How about Linux and Mac OS?

Check out: https://github.com/Mozilla-TWQA/B2G-flash-tool/blob/master/backup_restore_profile.sh

### Requirements:

- Windows 2000 and above (XP, Vista, 7, 8 or 10)
- ADB (Android Debug Bridge) tool
