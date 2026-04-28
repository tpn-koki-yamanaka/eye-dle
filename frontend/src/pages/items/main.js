fetch("/api/items")
  .then((res) => res.json())
  .then((items) => {
    const list = document.getElementById("item-list");
    items.forEach((item) => {
      const li = document.createElement("li");
      li.textContent = `${item.name} (ID: ${item.id})`;
      list.appendChild(li);
    });
  });
