fetch("/api/users")
  .then((res) => res.json())
  .then((users) => {
    const list = document.getElementById("user-list");
    users.forEach((user) => {
      const li = document.createElement("li");
      li.textContent = `${user.name} (ID: ${user.id})`;
      list.appendChild(li);
    });
  });
