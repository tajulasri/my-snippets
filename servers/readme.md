## Python fabric for laravel deployment

### Step 

1. clone this repository
2. pip install fabric

```php
env.hosts = [
    'your_server_ip'
]

env.user = 'your_ssh_username'
# you can use key instead

```

3. Run fab deploy and wait for task is finish.
```php
fab deploy:my-laravelsite.com
```


