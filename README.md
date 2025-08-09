# qb-businesscreator

**Overview**  
Illegal & Legal Business Creator/Manager for FiveM (QBCore) — supports both lawful and illicit business setups. :contentReference[oaicite:1]{index=1}

**Features**  
- Create and manage legal businesses (shops, services, etc.)  
- Create and manage illegal businesses (e.g. contraband operations)  
- Client and server support, HTML UI components included  
- SQL support for persistent data (in `sql/`)  
- Configurable via `config.lua` or UI editing  

**Requirements**  
- QBCore framework  
- qb-target or alternative for interaction zones  
- qb-menu or HTML UI integration (see `html/`)  

**Installation**  
1. Clone repository into your server’s resources folder.  
2. Add `ensure qb-businesscreator` to your `server.cfg`.  
3. Configure `config.lua` to define business behaviors.  
4. Run included SQL scripts in `sql/` for necessary tables.  
5. Verify that `fxmanifest.lua` dependencies match your installed resources.

**Usage**  
- Use in-game interaction zones to open business menus.  
- Manage business settings via `config.lua` or provided UI (if available).  
- Illegal and legal businesses function similarly, differentiated by settings.

**File Structure**  
