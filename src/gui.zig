const std = @import("std");

usingnamespace @cImport({
    @cInclude("gtk/gtk.h");
});

const columns = enum(c_int) {
    addr,
    raw,
    disasm,

    last = -1,
};

fn activate(app: *GtkApplication, user_data: gpointer) void {
    const window = @ptrCast(*GtkWindow, gtk_application_window_new(app));

    const store = gtk_list_store_new(3, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING);
    var iter: GtkTreeIter = undefined;
    gtk_list_store_append(store, &iter);
    gtk_list_store_set(store, &iter,
        columns.addr, "0x0001",
        columns.raw, "0xabcdef",
        columns.disasm, "foo",
        columns.last);

    const tree = @ptrCast(*GtkTreeView, gtk_tree_view_new_with_model(@ptrCast(*GtkTreeModel, store)));
    {
        const renderer = gtk_cell_renderer_text_new();
        const column = gtk_tree_view_column_new_with_attributes("Addr", renderer, "text", columns.addr, @as(?*c_void, null));
        _ = gtk_tree_view_append_column(tree, column);
    }
    {
        const renderer = gtk_cell_renderer_text_new();
        const column = gtk_tree_view_column_new_with_attributes("Raw", renderer, "text", columns.raw, @as(?*c_void, null));
        _ = gtk_tree_view_append_column(tree, column);
    }
    {
        const renderer = gtk_cell_renderer_text_new();
        const column = gtk_tree_view_column_new_with_attributes("Disasm", renderer, "text", columns.disasm, @as(?*c_void, null));
        _ = gtk_tree_view_append_column(tree, column);
    }

    gtk_window_set_child(window, @ptrCast(*GtkWidget, tree));
    gtk_window_present(window);
}

pub fn main() u8 {
    var app = gtk_application_new("belt.cpu", .G_APPLICATION_FLAGS_NONE);
    defer g_object_unref(app);

    _ = g_signal_connect_data(app, "activate", @ptrCast(GCallback, activate), null, null, @intToEnum(GConnectFlags, 0));
    const status = g_application_run(@ptrCast(*GApplication, app), 0, null);

    return @intCast(u8, status);
}
