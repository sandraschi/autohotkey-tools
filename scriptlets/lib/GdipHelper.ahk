; Minimal GDI+ helper for AHK v2 game rendering
; DllCall-based, no external dependencies

class GdipHelper {
    static token := 0
    static startupInput := 0

    static Startup() {
        if (GdipHelper.token)
            return
        si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
        NumPut("UInt", 1, si, 0)
        GdipHelper.token := 0
        DllCall("gdiplus.dll\GdiplusStartup", "UPtr*", &token := 0, "UPtr", si.Ptr, "UPtr", 0)
        GdipHelper.token := token
    }

    static Shutdown() {
        if (GdipHelper.token) {
            DllCall("gdiplus.dll\GdiplusShutdown", "UPtr", GdipHelper.token)
            GdipHelper.token := 0
        }
    }

    ; --- Bitmap / Graphics ---

    static CreateBitmap(w, h) {
        bm := 0
        DllCall("gdiplus.dll\GdipCreateBitmapFromScan0", "Int", w, "Int", h, "Int", 0, "Int", 0x26200A, "UPtr", 0, "UPtr*", &bm)
        return bm
    }

    static GraphicsFromImage(pBitmap) {
        g := 0
        DllCall("gdiplus.dll\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", &g)
        return g
    }

    static SetSmoothingMode(pGraphics, mode := 4) {
        ; 0=Default, 2=HighSpeed, 4=HighQuality, 5=None, 6=AntiAlias8x8
        DllCall("gdiplus.dll\GdipSetSmoothingMode", "UPtr", pGraphics, "Int", mode)
    }

    static Clear(pGraphics, argb := 0xFF000000) {
        DllCall("gdiplus.dll\GdipGraphicsClear", "UPtr", pGraphics, "UInt", argb)
    }

    ; --- Brushes ---

    static BrushCreateSolid(argb) {
        b := 0
        DllCall("gdiplus.dll\GdipCreateSolidFill", "UInt", argb, "UPtr*", &b)
        return b
    }

    static FillRectangle(pGraphics, pBrush, x, y, w, h) {
        DllCall("gdiplus.dll\GdipFillRectangle", "UPtr", pGraphics, "UPtr", pBrush, "Float", x, "Float", y, "Float", w, "Float", h)
    }

    static FillEllipse(pGraphics, pBrush, x, y, w, h) {
        DllCall("gdiplus.dll\GdipFillEllipse", "UPtr", pGraphics, "UPtr", pBrush, "Float", x, "Float", y, "Float", w, "Float", h)
    }

    ; --- Pens ---

    static PenCreate(argb, width := 1) {
        p := 0
        DllCall("gdiplus.dll\GdipCreatePen1", "UInt", argb, "Float", width, "Int", 2, "UPtr*", &p)
        return p
    }

    static DrawRectangle(pGraphics, pPen, x, y, w, h) {
        DllCall("gdiplus.dll\GdipDrawRectangle", "UPtr", pGraphics, "UPtr", pPen, "Float", x, "Float", y, "Float", w, "Float", h)
    }

    static DrawLine(pGraphics, pPen, x1, y1, x2, y2) {
        DllCall("gdiplus.dll\GdipDrawLine", "UPtr", pGraphics, "UPtr", pPen, "Float", x1, "Float", y1, "Float", x2, "Float", y2)
    }

    ; --- Cleanup ---

    static DisposeBrush(pBrush) {
        DllCall("gdiplus.dll\GdipDeleteBrush", "UPtr", pBrush)
    }

    static DisposePen(pPen) {
        DllCall("gdiplus.dll\GdipDeletePen", "UPtr", pPen)
    }

    static DisposeGraphics(pGraphics) {
        DllCall("gdiplus.dll\GdipDeleteGraphics", "UPtr", pGraphics)
    }

    static DisposeImage(pBitmap) {
        DllCall("gdiplus.dll\GdipDisposeImage", "UPtr", pBitmap)
    }

    ; --- GUI Picture control update ---

    static UpdatePicture(ctrl, pBitmap, w, h) {
        hbm := 0
        DllCall("gdiplus.dll\GdipCreateHBITMAPFromBitmap", "UPtr", pBitmap, "UPtr*", &hbm, "UInt", 0xFF000000)
        oldHbm := GdipHelper._hbmMap.Has(ctrl.Hwnd) ? GdipHelper._hbmMap[ctrl.Hwnd] : 0
        ctrl.Value := "HBITMAP:*" . hbm
        GdipHelper._hbmMap[ctrl.Hwnd] := hbm
        if (oldHbm)
            DllCall("DeleteObject", "UPtr", oldHbm)
        ; ensure control is sized correctly (first call only)
    }

    static _hbmMap := Map()
}
