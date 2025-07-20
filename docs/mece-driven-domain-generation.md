# 🛠️ Domain-Driven Hexagonal Project Generation: MECE-Driven Approach

## Overview
This documentation describes an improved, MECE-driven approach for generating project structure and code for each domain in your monorepo. Instead of hardcoding generic domains (like 'allocation', 'inventory'), you define your own domain-specific models and structure using clear, mutually exclusive and collectively exhaustive (MECE) lists. This enables precise, scalable, and maintainable code generation for any business context.

---

## 1. How It Works

1. **Define MECE Lists**: For each project/domain, create a set of text files (or a single YAML/JSON) listing the names for each category:
   - `entities.txt` (domain models)
   - `services.txt` (application services)
   - `ports.txt` (interfaces/ports)
   - `libs.txt` (shared libraries)
   - `apps.txt` (API/apps)
   - `tools.txt` (scripts/generators)
   - `docker.txt` (docker/infrastructure)

2. **Automated Generation**: A generator script reads these lists and creates the corresponding files and folders in the correct hexagonal structure, using templates for each type.

3. **Customization**: You can add or remove items from any list to tailor the generated code to your project's needs. Each name in a list results in a file/class/module with that name, following your naming conventions.

---

## 2. Example: Defining a Domain

Suppose you want to generate a domain for a project called `order-management`.

- `entities.txt`:
  - Order
  - OrderItem
  - Customer
- `services.txt`:
  - OrderService
  - CustomerService
- `ports.txt`:
  - OrderRepositoryPort
  - CustomerRepositoryPort
- `libs.txt`:
  - pricing
  - discounts
- `apps.txt`:
  - order-api
- `tools.txt`:
  - order-generator
- `docker.txt`:
  - order-db

---

## 3. Generation Process

1. **Read all MECE lists** for the target domain/project.
2. **For each category**, generate files/folders:
   - `entities` → `libs/<domain>/domain/entities/<name>.py`
   - `services` → `libs/<domain>/application/<name>.py`
   - `ports` → `libs/<domain>/adapters/<name>.py`
   - `libs` → `libs/<name>/`
   - `apps` → `apps/<name>/src/main.py`
   - `tools` → `tools/generators/<name>/`
   - `docker` → `docker/<name>.Dockerfile` or compose service
3. **Use templates** for each file type, inserting the name and following project conventions.
4. **Add __init__.py** where needed for Python packages.
5. **Validate**: Check for syntax, naming, and structure consistency.

---

## 4. Technical Debt Remediation & Enhancements
- **No hardcoded domain names**: All structure is driven by your MECE lists.
- **Consistent naming**: All files/classes use the names you provide, following project style.
- **Extensible**: Add new categories or templates as your architecture evolves.
- **Error handling**: The generator checks for duplicate names, missing files, and invalid characters.
- **Documentation-first**: Each generated domain includes a README summarizing its structure.
- **Test scaffolding**: Optionally generate test stubs for each entity/service.

---

## 5. Example Directory Structure (for `order-management`)

```
libs/
  order-management/
    domain/
      entities/
        Order.py
        OrderItem.py
        Customer.py
      ...
    application/
      OrderService.py
      CustomerService.py
    adapters/
      OrderRepositoryPort.py
      CustomerRepositoryPort.py
apps/
  order-api/
    src/
      main.py
libs/
  pricing/
  discounts/
tools/
  generators/
    order-generator/
docker/
  order-db.Dockerfile
```

---

## 6. Usage Instructions

1. **Create your MECE lists** in a folder (e.g., `project-definitions/order-management/`).
2. **Run the generator** (e.g., `python scripts/generate-domain.py order-management`).
3. **Review and customize** the generated code as needed.
4. **Repeat** for each new domain/project.

---

## 7. Best Practices
- Keep lists MECE: no overlaps, no omissions.
- Use clear, descriptive names.
- Review generated code for business logic and add tests.
- Document each domain with a README.
- Integrate with CI to validate structure and style.

---

## 8. Extending the Approach
- Add support for new categories (e.g., events, policies, value objects).
- Support YAML/JSON for richer config.
- Add hooks for custom templates.
- Integrate with Nx or other monorepo tools for orchestration.

---

## 9. Example Template (Entity)
```python
class {EntityName}:
    def __init__(self, ...):
        pass
```

---

## 10. Summary
This approach enables you to generate any domain/project structure in a scalable, maintainable, and business-driven way. All code and structure is defined by your MECE lists, ensuring clarity, consistency, and extensibility.
