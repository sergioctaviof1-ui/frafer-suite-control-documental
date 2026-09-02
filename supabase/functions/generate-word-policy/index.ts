import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import {
  AlignmentType,
  BorderStyle,
  Document,
  Footer,
  Header,
  HeightRule,
  PageNumber,
  Packer,
  Paragraph,
  ShadingType,
  Table,
  TableCell,
  TableRow,
  TextRun,
  VerticalAlign,
  WidthType,
} from "npm:docx@8";

// ── Paleta corporativa ────────────────────────────────────────────────────────
const NAVY   = "1C2B3A";
const MAUVE  = "9A6070";
const GRAY   = "9C8E84";
const CREAM  = "F0E8DC";
const BORDER = "C8BFB5";
const GREEN  = "2D6B47";
const WHITE  = "FFFFFF";

// ── Utilidades ────────────────────────────────────────────────────────────────
const dash = (s: unknown) => (s && String(s).trim()) ? String(s).trim() : "—";

const BORD_NAVY: Record<string, { style: BorderStyle; size: number; color: string }> = {
  top:    { style: BorderStyle.SINGLE, size: 18, color: NAVY },
  bottom: { style: BorderStyle.SINGLE, size: 18, color: NAVY },
  left:   { style: BorderStyle.SINGLE, size: 18, color: NAVY },
  right:  { style: BorderStyle.SINGLE, size: 18, color: NAVY },
};
const BORD_THIN: Record<string, { style: BorderStyle; size: number; color: string }> = {
  top:    { style: BorderStyle.SINGLE, size: 8, color: BORDER },
  bottom: { style: BorderStyle.SINGLE, size: 8, color: BORDER },
  left:   { style: BorderStyle.SINGLE, size: 8, color: BORDER },
  right:  { style: BorderStyle.SINGLE, size: 8, color: BORDER },
};
const BORD_NONE: Record<string, { style: BorderStyle }> = {
  top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE },
  left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE },
};

// Celda de espacio para firma
const sigSpace = (w: number) => new TableCell({
  width: { size: w, type: WidthType.DXA },
  borders: BORD_THIN,
  height: { value: 900, rule: HeightRule.ATLEAST },
  children: [new Paragraph({ text: "" })],
});

// ── Constructor del documento ─────────────────────────────────────────────────
// deno-lint-ignore no-explicit-any
function buildDoc(d: Record<string, any>): Document {
  const TW  = 9720; // ancho de texto en twips (letter 12240 - L1440 - R1080)
  const Q   = Math.round(TW * 0.25);
  const H   = Math.round(TW * 0.50);
  const Q3  = Math.round(TW * 0.75);
  const W3  = Math.round(TW / 3);
  const W3b = Math.round(TW * 2 / 3);

  // ════════════════════════════════════════════════════════════════
  // ENCABEZADO — se repite en cada página
  // ════════════════════════════════════════════════════════════════
  const docHeader = new Header({
    children: [
      new Table({
        width: { size: TW, type: WidthType.DXA },
        borders: {
          ...BORD_NONE,
          bottom: { style: BorderStyle.SINGLE, size: 20, color: NAVY },
          insideH: { style: BorderStyle.NONE },
          insideV: { style: BorderStyle.NONE },
        },
        rows: [new TableRow({
          children: [
            // Izq: Folio en Courier
            new TableCell({
              width: { size: Math.round(TW * 0.30), type: WidthType.DXA },
              borders: BORD_NONE,
              verticalAlign: VerticalAlign.BOTTOM,
              children: [new Paragraph({
                spacing: { after: 60 },
                children: [new TextRun({
                  text: dash(d.folio),
                  bold: true, color: MAUVE,
                  font: "Courier New", size: 17,
                })],
              })],
            }),
            // Centro: Nombre de política
            new TableCell({
              width: { size: Math.round(TW * 0.42), type: WidthType.DXA },
              borders: BORD_NONE,
              verticalAlign: VerticalAlign.BOTTOM,
              children: [new Paragraph({
                alignment: AlignmentType.CENTER,
                spacing: { after: 60 },
                children: [new TextRun({
                  text: String(d.nombre || "").slice(0, 46),
                  color: NAVY, font: "Calibri", size: 16,
                })],
              })],
            }),
            // Der: GRUPO MORSA
            new TableCell({
              width: { size: Math.round(TW * 0.28), type: WidthType.DXA },
              borders: BORD_NONE,
              verticalAlign: VerticalAlign.BOTTOM,
              children: [new Paragraph({
                alignment: AlignmentType.RIGHT,
                spacing: { after: 60 },
                children: [new TextRun({
                  text: "GRUPO MORSA",
                  bold: true, color: NAVY,
                  font: "Calibri", size: 19,
                })],
              })],
            }),
          ],
        })],
      }),
    ],
  });

  // ════════════════════════════════════════════════════════════════
  // PIE DE PÁGINA — se repite en cada página
  // ════════════════════════════════════════════════════════════════
  const docFooter = new Footer({
    children: [
      new Table({
        width: { size: TW, type: WidthType.DXA },
        borders: {
          ...BORD_NONE,
          top: { style: BorderStyle.SINGLE, size: 8, color: BORDER },
          insideH: { style: BorderStyle.NONE },
          insideV: { style: BorderStyle.NONE },
        },
        rows: [
          new TableRow({
            children: [
              new TableCell({
                width: { size: Math.round(TW * 0.78), type: WidthType.DXA },
                borders: BORD_NONE,
                children: [new Paragraph({
                  spacing: { before: 60 },
                  children: [new TextRun({
                    text: `Elaboró: ${dash(d.respElab)}  ·  Autorizó: ${dash(d.autorizadoPor)}  ·  Vigente: ${dash(d.fechaAutorizacion)} – ${dash(d.fechaVencimiento)}`,
                    color: GRAY, font: "Calibri", size: 13,
                  })],
                })],
              }),
              new TableCell({
                width: { size: Math.round(TW * 0.22), type: WidthType.DXA },
                borders: BORD_NONE,
                children: [new Paragraph({
                  alignment: AlignmentType.RIGHT,
                  spacing: { before: 60 },
                  children: [
                    new TextRun({ text: "Pág. ", color: GRAY, font: "Calibri", size: 15 }),
                    new TextRun({ children: [PageNumber.CURRENT], color: GRAY, font: "Calibri", size: 15 }),
                    new TextRun({ text: " / ", color: GRAY, font: "Calibri", size: 15 }),
                    new TextRun({ children: [PageNumber.TOTAL_PAGES], color: GRAY, font: "Calibri", size: 15 }),
                  ],
                })],
              }),
            ],
          }),
          new TableRow({
            children: [new TableCell({
              columnSpan: 2,
              borders: BORD_NONE,
              children: [new Paragraph({
                children: [new TextRun({
                  text: `Grupo Morsa  ·  Control Documental  ·  Uso Interno  ·  Generado el ${d.generadoEl || ""}`,
                  color: GRAY, font: "Calibri", size: 11,
                })],
              })],
            })],
          }),
        ],
      }),
    ],
  });

  // ════════════════════════════════════════════════════════════════
  // HELPERS para cuerpo del documento
  // ════════════════════════════════════════════════════════════════

  // Fila de barra navy (encabezado de sección)
  const navyBar = (text: string, colSpan = 4) =>
    new TableRow({
      children: [new TableCell({
        columnSpan: colSpan,
        shading: { type: ShadingType.SOLID, color: NAVY },
        borders: BORD_NAVY,
        children: [new Paragraph({
          spacing: { before: 60, after: 60 },
          children: [new TextRun({
            text: `  ${text}`,
            bold: true, color: WHITE,
            font: "Calibri", size: 18,
          })],
        })],
      })],
    });

  // Fila de control [etiqueta crema | valor | etiqueta crema | valor]
  const ctRow = (l1: string, v1: string, l2: string, v2: string) =>
    new TableRow({
      children: [
        new TableCell({ width: { size: Q, type: WidthType.DXA }, borders: BORD_THIN,
          shading: { type: ShadingType.SOLID, color: CREAM },
          children: [new Paragraph({ spacing: { before: 40, after: 40 },
            children: [new TextRun({ text: l1, bold: true, color: GRAY, font: "Calibri", size: 15 })] })] }),
        new TableCell({ width: { size: H - Q, type: WidthType.DXA }, borders: BORD_THIN,
          children: [new Paragraph({ spacing: { before: 40, after: 40 },
            children: [new TextRun({ text: v1, font: "Calibri", size: 18 })] })] }),
        new TableCell({ width: { size: Q3 - H, type: WidthType.DXA }, borders: BORD_THIN,
          shading: { type: ShadingType.SOLID, color: CREAM },
          children: [new Paragraph({ spacing: { before: 40, after: 40 },
            children: [new TextRun({ text: l2, bold: true, color: GRAY, font: "Calibri", size: 15 })] })] }),
        new TableCell({ width: { size: TW - Q3, type: WidthType.DXA }, borders: BORD_THIN,
          children: [new Paragraph({ spacing: { before: 40, after: 40 },
            children: [new TextRun({ text: v2, font: "Calibri", size: 18 })] })] }),
      ],
    });

  // Separador de grupo (texto gris pequeño + línea)
  const groupLabel = (text: string) => new Paragraph({
    spacing: { before: 280, after: 80 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: BORDER } },
    children: [new TextRun({
      text: text.toUpperCase(),
      bold: true, smallCaps: true,
      color: GRAY, font: "Calibri", size: 15,
    })],
  });

  // Sección (barra navy + párrafos de contenido)
  let sNum = 0;
  const makeSection = (title: string, body: string | null): (Paragraph | Table)[] => {
    if (!body?.trim()) return [];
    sNum++;
    const lines = body.split("\n").filter(l => l.trim());
    return [
      new Table({
        width: { size: TW, type: WidthType.DXA },
        rows: [navyBar(`${sNum}. ${title.toUpperCase()}`)],
      }),
      ...lines.map(line => new Paragraph({
        spacing: { before: 0, after: 60 },
        indent: { left: 120, right: 120 },
        children: [new TextRun({ text: line, font: "Calibri", size: 20, color: "1a1a1a" })],
      })),
      new Paragraph({ spacing: { before: 100, after: 0 }, text: "" }),
    ];
  };

  // ════════════════════════════════════════════════════════════════
  // BLOQUE DE TÍTULO
  // ════════════════════════════════════════════════════════════════
  const titleTable = new Table({
    width: { size: TW, type: WidthType.DXA },
    rows: [
      // Fila 1: GRUPO MORSA (navy) | Folio + Versión (crema)
      new TableRow({
        children: [
          new TableCell({
            columnSpan: 2,
            width: { size: Math.round(TW * 0.62), type: WidthType.DXA },
            shading: { type: ShadingType.SOLID, color: NAVY },
            borders: BORD_NAVY,
            children: [
              new Paragraph({ spacing: { before: 80 }, children: [
                new TextRun({ text: "  GRUPO MORSA", bold: true, color: WHITE, font: "Calibri", size: 22 }),
              ]}),
              new Paragraph({ spacing: { after: 80 }, children: [
                new TextRun({ text: "  Control Documental  ·  Política Organizacional", color: MAUVE, font: "Calibri", size: 13 }),
              ]}),
            ],
          }),
          new TableCell({
            columnSpan: 2,
            width: { size: Math.round(TW * 0.38), type: WidthType.DXA },
            shading: { type: ShadingType.SOLID, color: CREAM },
            borders: BORD_NAVY,
            verticalAlign: VerticalAlign.CENTER,
            children: [
              new Paragraph({ alignment: AlignmentType.RIGHT, spacing: { before: 60 }, children: [
                new TextRun({ text: `${dash(d.folio)}  `, bold: true, color: MAUVE, font: "Courier New", size: 26 }),
              ]}),
              new Paragraph({ alignment: AlignmentType.RIGHT, spacing: { after: 60 }, children: [
                new TextRun({ text: `Versión ${d.version}  ·  Uso Interno  `, color: GRAY, font: "Calibri", size: 14 }),
              ]}),
            ],
          }),
        ],
      }),
      // Fila 2: Nombre completo (crema, ancho total)
      new TableRow({
        children: [new TableCell({
          columnSpan: 4,
          shading: { type: ShadingType.SOLID, color: CREAM },
          borders: BORD_NAVY,
          children: [
            new Paragraph({ spacing: { before: 100 }, children: [
              new TextRun({ text: `  ${dash(d.nombre)}`, bold: true, color: NAVY, font: "Calibri", size: 26 }),
            ]}),
            new Paragraph({ spacing: { after: 100 }, children: [
              new TextRun({ text: `  ${dash(d.dir)}`, color: GRAY, font: "Calibri", size: 13 }),
            ]}),
          ],
        })],
      }),
      // Filas de control
      ctRow("ESTADO",              dash(d.status),           "DIRECCIÓN RESPONSABLE", dash(d.respDir)),
      ctRow("VIGENCIA",            d.vigenciaMeses ? `${d.vigenciaMeses} meses` : "—", "ELABORÓ", dash(d.respElab)),
      ctRow("FECHA AUTORIZACIÓN",  dash(d.fechaAutorizacion), "AUTORIZÓ",             dash(d.autorizadoPor)),
      ctRow("VIGENTE HASTA",       dash(d.fechaVencimiento),  "COLABORADORES",        dash(d.colaboradores)),
      ...(d.numReglas ? [ctRow("# DE REGLAS", String(d.numReglas), "", "")] : []),
      // Franja de jerarquía (verde)
      new TableRow({
        children: [new TableCell({
          columnSpan: 4,
          shading: { type: ShadingType.SOLID, color: GREEN },
          borders: BORD_THIN,
          children: [new Paragraph({
            spacing: { before: 40, after: 40 },
            children: [new TextRun({
              text: `  ${dash(d.dir)}  ›  ${dash(d.area)}  ›  ${dash(d.dept)}  ›  ${dash(d.act)}`,
              color: WHITE, font: "Calibri", size: 15,
            })],
          })],
        })],
      }),
    ],
  });

  // ════════════════════════════════════════════════════════════════
  // TABLA DE FIRMAS
  // ════════════════════════════════════════════════════════════════
  const sigTable = new Table({
    width: { size: TW, type: WidthType.DXA },
    rows: [
      new TableRow({ children: [new TableCell({
        columnSpan: 3, shading: { type: ShadingType.SOLID, color: NAVY }, borders: BORD_NAVY,
        children: [new Paragraph({ spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "  CONTROL DE APROBACIONES", bold: true, color: WHITE, font: "Calibri", size: 18 }),
        ]})],
      })] }),
      new TableRow({ children: ["ELABORÓ", "REVISÓ", "AUTORIZÓ"].map((r, i) =>
        new TableCell({
          width: { size: i < 2 ? W3 : TW - W3b, type: WidthType.DXA },
          shading: { type: ShadingType.SOLID, color: CREAM }, borders: BORD_THIN,
          children: [new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 40, after: 40 }, children: [
            new TextRun({ text: r, bold: true, color: GRAY, font: "Calibri", size: 16 }),
          ]})],
        })) }),
      // Espacio de firma
      new TableRow({
        height: { value: 900, rule: HeightRule.ATLEAST },
        children: [sigSpace(W3), sigSpace(W3), sigSpace(TW - W3b)],
      }),
      // Nombres
      new TableRow({ children: [
        new TableCell({ width: { size: W3, type: WidthType.DXA }, borders: BORD_THIN,
          children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [
            new TextRun({ text: dash(d.respElab), bold: true, font: "Calibri", size: 19 })] })] }),
        new TableCell({ width: { size: W3, type: WidthType.DXA }, borders: BORD_THIN,
          children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [
            new TextRun({ text: "___________________________", font: "Calibri", size: 18 })] })] }),
        new TableCell({ width: { size: TW - W3b, type: WidthType.DXA }, borders: BORD_THIN,
          children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [
            new TextRun({ text: dash(d.autorizadoPor), bold: true, font: "Calibri", size: 19 })] })] }),
      ]}),
      // "Nombre y Firma"
      new TableRow({ children: ["Nombre y Firma", "Nombre y Firma", "Nombre y Firma"].map((t, i) =>
        new TableCell({
          width: { size: i < 2 ? W3 : TW - W3b, type: WidthType.DXA }, borders: BORD_THIN,
          children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [
            new TextRun({ text: t, color: GRAY, font: "Calibri", size: 14 })] })] })) }),
    ],
  });

  // ════════════════════════════════════════════════════════════════
  // HISTORIAL DE REVISIONES
  // ════════════════════════════════════════════════════════════════
  const hPcts = [0.10, 0.28, 0.47, 0.60, 0.80, 1.00];
  const hEdges = hPcts.map(f => Math.round(TW * f));
  const hWidths = hEdges.map((x, i) => i === 0 ? x : x - hEdges[i - 1]);
  const hLabels = ["Ver.", "Estado", "Fecha Aut.", "Vigencia", "Elaboró", "Autorizó"];
  const hValues = [
    String(d.version || 1),
    dash(d.status),
    dash(d.fechaAutorizacion),
    d.vigenciaMeses ? `${d.vigenciaMeses} meses` : "—",
    dash(d.respElab),
    dash(d.autorizadoPor),
  ];

  const histTable = new Table({
    width: { size: TW, type: WidthType.DXA },
    rows: [
      new TableRow({ children: [new TableCell({
        columnSpan: 6, shading: { type: ShadingType.SOLID, color: NAVY }, borders: BORD_NAVY,
        children: [new Paragraph({ spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "  HISTORIAL DE REVISIONES", bold: true, color: WHITE, font: "Calibri", size: 18 }),
        ]})],
      })] }),
      new TableRow({ children: hLabels.map((l, i) => new TableCell({
        width: { size: hWidths[i], type: WidthType.DXA },
        shading: { type: ShadingType.SOLID, color: CREAM }, borders: BORD_THIN,
        children: [new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 40, after: 40 }, children: [
          new TextRun({ text: l, bold: true, color: GRAY, font: "Calibri", size: 15 }),
        ]})],
      })) }),
      new TableRow({ children: hValues.map((v, i) => new TableCell({
        width: { size: hWidths[i], type: WidthType.DXA }, borders: BORD_THIN,
        children: [new Paragraph({
          alignment: i === 0 ? AlignmentType.CENTER : AlignmentType.LEFT,
          spacing: { before: 40, after: 40 },
          children: [new TextRun({
            text: v,
            bold: i === 0, font: i === 0 ? "Courier New" : "Calibri", size: 18,
          })],
        })],
      })) }),
    ],
  });

  // ════════════════════════════════════════════════════════════════
  // ENSAMBLAR DOCUMENTO
  // ════════════════════════════════════════════════════════════════
  return new Document({
    creator: "Frafer Suite — Control Documental",
    title: dash(d.nombre),
    description: `Política ${dash(d.folio)} — Grupo Morsa`,
    sections: [{
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1080, bottom: 1440, left: 1440, header: 720, footer: 720 },
        },
      },
      headers: { default: docHeader },
      footers: { default: docFooter },
      children: [
        titleTable,
        new Paragraph({ spacing: { before: 160, after: 0 }, text: "" }),

        groupLabel("Contenido de la Política"),
        ...makeSection("Propósito y Objetivo",        d.objeto),
        ...makeSection("Alcance",                     d.alcance),
        ...makeSection("Definiciones",                d.definiciones),
        ...makeSection("Lineamientos y Reglas",       d.contenido),
        ...makeSection("Sanciones por Incumplimiento",d.sanciones),
        ...makeSection("Excepciones",                 d.excepciones),

        groupLabel("Comunicación e Implementación"),
        ...makeSection("Canal de Comunicación",        d.canal),
        ...makeSection("Esquema de Capacitación",      d.capacitacion),
        ...makeSection("Directrices y Valores Asociados", d.directrices),

        new Paragraph({ spacing: { before: 280, after: 0 }, text: "" }),
        sigTable,
        new Paragraph({ spacing: { before: 280, after: 0 }, text: "" }),
        histTable,
      ],
    }],
  });
}

// ── Servidor ──────────────────────────────────────────────────────────────────
serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const data = await req.json();
    const doc    = buildDoc(data);
    const buffer = await Packer.toBuffer(doc);
    const folio  = String(data.folio || "politica").replace(/[^\w-]/g, "_");
    const ver    = String(data.version || "1");

    return new Response(buffer, {
      headers: {
        ...corsHeaders,
        "Content-Type":
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "Content-Disposition": `attachment; filename="${folio}_v${ver}.docx"`,
      },
    });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
