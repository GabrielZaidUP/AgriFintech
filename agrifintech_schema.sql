-- ============================================================
--  AgriFintech Platform — Database Schema
--  Phase A: DDL + Seed Data
--  Database: PostgreSQL 15 (Neon.tech)
-- ============================================================

-- ── DDL: Create Tables ───────────────────────────────────────

CREATE TABLE producers (
    producer_id   SERIAL          PRIMARY KEY,
    full_name     VARCHAR(120)    NOT NULL,
    email         VARCHAR(120)    NOT NULL UNIQUE,
    phone         VARCHAR(20),
    region        VARCHAR(80)     NOT NULL,
    producer_type VARCHAR(20)     NOT NULL
        CHECK (producer_type IN ('crop', 'livestock', 'both')),
    created_at    TIMESTAMP       NOT NULL DEFAULT NOW()
);

CREATE TABLE commodities (
    commodity_id  SERIAL          PRIMARY KEY,
    name          VARCHAR(80)     NOT NULL UNIQUE,
    category      VARCHAR(20)     NOT NULL
        CHECK (category IN ('crop', 'livestock')),
    unit          VARCHAR(20)     NOT NULL,
    base_price    NUMERIC(12, 2)  NOT NULL
);

CREATE TABLE financial_products (
    product_id      SERIAL          PRIMARY KEY,
    name            VARCHAR(120)    NOT NULL,
    product_type    VARCHAR(20)     NOT NULL
        CHECK (product_type IN ('loan', 'insurance', 'credit_line')),
    interest_rate   NUMERIC(5, 2),
    max_amount      NUMERIC(14, 2)  NOT NULL,
    duration_months INT,
    description     TEXT
);

CREATE TABLE producer_commodities (
    producer_id   INT  NOT NULL REFERENCES producers(producer_id)
                                ON DELETE CASCADE,
    commodity_id  INT  NOT NULL REFERENCES commodities(commodity_id)
                                ON DELETE CASCADE,
    quantity      NUMERIC(12, 2) NOT NULL,
    harvest_date  DATE,
    PRIMARY KEY (producer_id, commodity_id)
);

CREATE TABLE transactions (
    transaction_id  SERIAL          PRIMARY KEY,
    producer_id     INT  NOT NULL REFERENCES producers(producer_id),
    product_id      INT  NOT NULL REFERENCES financial_products(product_id),
    amount          NUMERIC(14, 2)  NOT NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected', 'paid')),
    notes           TEXT,
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ── Seed Data ────────────────────────────────────────────────

-- producers (12 rows)
INSERT INTO producers (full_name, email, phone, region, producer_type, created_at) VALUES
('Carlos Mendoza Ríos',    'carlos.mendoza@agri.mx',   '618-234-5678', 'Durango',       'crop',      '2023-01-15 09:00:00'),
('María Gutiérrez López',  'maria.gutierrez@agri.mx',  '473-891-2345', 'Guanajuato',    'both',      '2023-02-03 10:30:00'),
('José Ramírez Herrera',   'jose.ramirez@agri.mx',     '686-345-6789', 'Sonora',        'livestock', '2023-02-20 08:15:00'),
('Ana Torres Castillo',    'ana.torres@agri.mx',       '322-456-7890', 'Jalisco',       'crop',      '2023-03-05 11:00:00'),
('Luis Flores Morales',    'luis.flores@agri.mx',      '871-567-8901', 'Chihuahua',     'livestock', '2023-03-18 14:45:00'),
('Rosa Jiménez Vega',      'rosa.jimenez@agri.mx',     '951-678-9012', 'Oaxaca',        'crop',      '2023-04-02 09:30:00'),
('Pedro Álvarez Soto',     'pedro.alvarez@agri.mx',    '833-789-0123', 'Tamaulipas',    'both',      '2023-04-15 13:00:00'),
('Elena Cruz Martínez',    'elena.cruz@agri.mx',       '744-890-1234', 'Zacatecas',     'crop',      '2023-05-07 08:00:00'),
('Miguel Reyes Ortega',    'miguel.reyes@agri.mx',     '777-901-2345', 'Veracruz',      'livestock', '2023-05-22 15:30:00'),
('Laura Moreno Díaz',      'laura.moreno@agri.mx',     '462-012-3456', 'Michoacán',     'both',      '2023-06-10 10:00:00'),
('Roberto Vargas Peña',    'roberto.vargas@agri.mx',   '867-123-4567', 'Nuevo León',    'crop',      '2023-06-28 11:45:00'),
('Carmen Salinas Rojas',   'carmen.salinas@agri.mx',   '998-234-5678', 'Yucatán',       'livestock', '2023-07-14 09:15:00');

-- commodities (12 rows)
INSERT INTO commodities (name, category, unit, base_price) VALUES
('Maíz',           'crop',      'ton',   3200.00),
('Trigo',          'crop',      'ton',   4800.00),
('Sorgo',          'crop',      'ton',   2900.00),
('Frijol',         'crop',      'ton',  18500.00),
('Chile Seco',     'crop',      'ton',  42000.00),
('Tomate',         'crop',      'ton',   8500.00),
('Aguacate',       'crop',      'ton',  28000.00),
('Ganado Bovino',  'livestock', 'head', 22000.00),
('Ganado Porcino', 'livestock', 'head',  4200.00),
('Ganado Caprino', 'livestock', 'head',  2800.00),
('Aves de Corral', 'livestock', 'head',   180.00),
('Ovinos',         'livestock', 'head',  3500.00);

-- financial_products (11 rows)
INSERT INTO financial_products
    (name, product_type, interest_rate, max_amount, duration_months, description)
VALUES
('Crédito Siembra',            'loan',        9.50,   500000.00, 12,   'Préstamo para insumos de siembra de temporada'),
('Crédito Cosecha Plus',       'loan',        8.75,   800000.00, 18,   'Financiamiento para producción de ciclo largo'),
('Crédito Ganadero',           'loan',       10.20,  1200000.00, 24,   'Adquisición y engorda de ganado bovino y porcino'),
('Línea Agro Express',         'credit_line', 11.00,  300000.00, NULL, 'Línea revolvente para gastos operativos urgentes'),
('Línea Ganadera Revolvente',  'credit_line', 10.50,  600000.00, NULL, 'Crédito revolvente para insumos pecuarios'),
('Seguro Multiriesgo Agrícola','insurance',   NULL,   150000.00, NULL, 'Cobertura contra sequía, helada e inundación para cultivos'),
('Seguro Pecuario Integral',   'insurance',   NULL,   200000.00, NULL, 'Seguro de vida y enfermedad para bovinos y porcinos'),
('Seguro Granizo',             'insurance',   NULL,    80000.00, NULL, 'Cobertura específica contra daño por granizo'),
('Crédito Tecnificación',      'loan',        7.80,  2000000.00, 36,   'Adquisición de maquinaria, riego e infraestructura'),
('Crédito Joven Agricultor',   'loan',        6.50,   400000.00, 24,   'Tasa preferencial para productores menores de 35 años'),
('Línea Capital de Trabajo',   'credit_line', 12.00,  250000.00, NULL, 'Financiamiento a corto plazo para capital de trabajo');

-- producer_commodities (14 rows)
INSERT INTO producer_commodities (producer_id, commodity_id, quantity, harvest_date) VALUES
(1,   1,   850.00, '2024-11-15'),   -- Carlos Mendoza     → Maíz
(1,   3,   420.00, '2024-10-30'),   -- Carlos Mendoza     → Sorgo
(2,   2,   620.00, '2024-12-01'),   -- María Gutiérrez    → Trigo
(2,   8,    45.00, NULL),           -- María Gutiérrez    → Ganado Bovino
(3,   8,   120.00, NULL),           -- José Ramírez       → Ganado Bovino
(3,   9,   200.00, NULL),           -- José Ramírez       → Ganado Porcino
(4,   6,   300.00, '2024-09-20'),   -- Ana Torres         → Tomate
(4,   7,   180.00, '2024-08-15'),   -- Ana Torres         → Aguacate
(5,   8,    80.00, NULL),           -- Luis Flores        → Ganado Bovino
(5,  12,   150.00, NULL),           -- Luis Flores        → Ovinos
(6,   4,    95.00, '2024-11-01'),   -- Rosa Jiménez       → Frijol
(6,   5,    12.50, '2024-10-10'),   -- Rosa Jiménez       → Chile Seco
(7,   1,  1200.00, '2024-11-20'),   -- Pedro Álvarez      → Maíz
(10,  7,   250.00, '2024-08-30');   -- Laura Moreno       → Aguacate

-- transactions (13 rows)
INSERT INTO transactions (producer_id, product_id, amount, status, notes, created_at) VALUES
(1,   1,  320000.00, 'approved',  'Siembra de maíz ciclo PV 2024',            '2024-01-10 10:00:00'),
(1,   9,  850000.00, 'paid',      'Compra de tractor y sistema de riego',      '2023-08-15 09:30:00'),
(2,   2,  450000.00, 'approved',  'Expansión de producción triguera',          '2024-02-05 11:00:00'),
(2,   3,  380000.00, 'pending',   'Adquisición ganado para engorda',           '2024-06-20 14:00:00'),
(3,   3,  750000.00, 'approved',  'Compra de 60 cabezas bovinas',              '2024-03-01 08:45:00'),
(3,   7,  180000.00, 'approved',  'Seguro pecuario bovinos 2024',              '2024-01-20 10:30:00'),
(4,   1,  180000.00, 'paid',      'Insumos para cultivo de tomate',            '2023-09-10 09:00:00'),
(4,   6,   95000.00, 'approved',  'Cobertura multiriesgo para huerto aguacate','2024-04-05 13:15:00'),
(5,   3,  620000.00, 'rejected',  'Documentación incompleta de garantías',     '2024-02-28 15:00:00'),
(6,  10,  280000.00, 'approved',  'Joven agricultor — ciclo chile y frijol',   '2024-03-15 10:00:00'),
(7,   4,  150000.00, 'pending',   'Capital de trabajo Q3 2024',               '2024-07-01 11:30:00'),
(10,  2,  680000.00, 'approved',  'Ampliación huerta aguacate Michoacán',      '2024-04-18 09:45:00'),
(12,  7,  195000.00, 'paid',      'Seguro pecuario avicultura Yucatán',        '2023-11-05 08:00:00');

-- ── Read-only API user (run as superuser on Neon) ────────────
-- CREATE USER api_user WITH PASSWORD 'your_secure_password';
-- GRANT CONNECT ON DATABASE neondb TO api_user;
-- GRANT USAGE ON SCHEMA public TO api_user;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO api_user;
