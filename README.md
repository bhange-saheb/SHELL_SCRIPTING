# USER AUTOMATION Process

## Backup the sshd_config file
```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
```
## Modify the sshd_config file to enable password authentication
```bash
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
grep -r "PasswordAuthentication" /etc/ssh/sshd_config.d/ # ---> this will give file location where we havbe to update

nano #file make no to yes
```
## Restart the SSH service
```bash
sudo service sshd restart
```

# Variable assignment. 
## Here are the different ways to assign and use variables correctly.

### 1. Basic variable assignment

```bash
NAME="John"
```

Access it with:

```bash
echo "$NAME"
```

Output:

```text
John
```

**Rule:** There must be **no spaces** around `=`.

✅ Correct

```bash
NAME="John"
```

❌ Wrong

```bash
NAME = "John"
```

---

### 2. Assigning command output (Command Substitution)

Use `$()`.

```bash
DATE=$(date)
```

or

```bash
CURRENT_USER=$(whoami)
```

Example:

```bash
echo "$CURRENT_USER"
```

Output:

```text
ubuntu
```

This is exactly what you used:

```bash
EXISTING_USER=$(grep -iw "^$USER:" /etc/passwd | cut -d: -f1)
```

Here:

* `grep ...` runs
* Its output is stored in `EXISTING_USER`

---

### 3. Assigning numbers

```bash
AGE=25
```

Print:

```bash
echo "$AGE"
```

---

### 4. Assigning strings

```bash
CITY="Chicago"
```

Print:

```bash
echo "$CITY"
```

---

### 5. Assigning another variable

```bash
NAME="Rahul"

USERNAME="$NAME"
```

Now

```bash
echo "$USERNAME"
```

prints

```text
Rahul
```

---

### 6. Reading input from user

```bash
read NAME
```

or

```bash
read -p "Enter your name: " NAME
```

---

### 7. Using environment variables

These are already defined by the shell.

Examples:

```bash
echo "$HOME"
```

```bash
echo "$PATH"
```

```bash
echo "$USER"
```

---

### 8. Using variables in strings

```bash
NAME="Rahul"

echo "Welcome $NAME"
```

Output

```text
Welcome Rahul
```

---

### 9. Arithmetic assignment

```bash
NUM=10

RESULT=$((NUM + 5))
```

Output

```bash
echo "$RESULT"
```

```
15
```

---

### 10. Random number

```bash
RANDOM_NO=$RANDOM
```

Example output

```
23561
```

---

### 11. Assigning with `export`

Makes the variable available to child processes.

```bash
export JAVA_HOME=/usr/lib/jvm/java-17
```

Verify:

```bash
echo "$JAVA_HOME"
```

---

### 12. Local variable inside a function

```bash
greet() {
    local NAME="John"
    echo "$NAME"
}
```

`local` means the variable exists only inside that function.

---

## Common mistakes

###  Mistake 1: Using `$(VARIABLE)` instead of `$VARIABLE`

Wrong:

```bash
if [ "$(USER)" = "$(EXISTING_USER)" ]
```

`$(...)` executes a command, so Bash looks for a command named `USER`.

Correct:

```bash
if [ "$USER" = "$EXISTING_USER" ]
```

---

###  Mistake 2: Spaces around `=`

Wrong:

```bash
NAME = Rahul
```

Correct:

```bash
NAME="Rahul"
```

---

###  Mistake 3: Not quoting variables

Instead of:

```bash
echo $NAME
```

prefer:

```bash
echo "$NAME"
```

Quoting helps prevent issues if the value contains spaces or special characters.

---

# Our script example explained

```bash
USER="john"

EXISTING_USER=$(grep -iw "^$USER:" /etc/passwd | cut -d: -f1)

if [ "$USER" = "$EXISTING_USER" ]; then
    echo "User exists"
else
    echo "User does not exist"
fi
```

**Execution flow:**

1. `USER` gets the value `john`.
2. `grep` searches for `john` in `/etc/passwd`.
3. `cut` extracts the username.
4. The result is stored in `EXISTING_USER`.
5. The `if` statement compares the two variables.
6. If they're equal, the script prints `"User exists"`.

**learning Bash, focus on these core concepts**

* Variable assignment (`NAME=value`)
* Variable expansion (`$NAME`)
* Command substitution (`$(command)`)
* Quoting variables (`"$NAME"`)
* Environment variables (like `$HOME` and `$PATH`)

These form the foundation for writing reliable shell scripts.
