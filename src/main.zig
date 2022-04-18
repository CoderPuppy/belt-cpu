const std = @import("std");

const G = @cImport({
    @cInclude("gtk/gtk.h");
});

const instrs_columns = enum(c_int) {
    addr,
    raw,
    disasm,

    last = -1,
};

const BeltyMemoryStore = struct { parent_instance: G.GObject };
const BeltyMemoryStorePrivate = struct { wat: u8 };
const BeltyMemoryStoreClass = struct { parent_class: G.GObjectClass };
var belty_memory_store_parent_class: G.gpointer = null;
var belty_memory_store_type_id: G.gsize = 0;
var BeltyMemoryStore_private_offset: G.gint = undefined;
fn belty_memory_store_class_intern_init(class: G.gpointer, data: G.gpointer) callconv(.C) void {
    belty_memory_store_parent_class = G.g_type_class_peek_parent(class);
    if (BeltyMemoryStore_private_offset != 0)
        G.g_type_class_adjust_private_offset(class, &BeltyMemoryStore_private_offset);
}
fn belty_memory_store_init(self: ?*G.GTypeInstance, class: G.gpointer) callconv(.C) void {}
fn belty_memory_store_get_n_columns(tree_model: ?*G.GtkTreeModel) callconv(.C) c_int {
    return 5;
}
fn belty_memory_store_get_column_type(tree_model: ?*G.GtkTreeModel, index: c_int) callconv(.C) G.GType {
    return G.G_TYPE_STRING;
}
fn belty_memory_store_list_model_init(ifaceP: G.gpointer, data: G.gpointer) callconv(.C) void {
    const iface = @ptrCast(*G.GtkTreeModelIface, @alignCast(@alignOf(G.GtkTreeModelIface), ifaceP));
    iface.get_n_columns = belty_memory_store_get_n_columns;
    iface.get_column_type = belty_memory_store_get_column_type;
}
export fn belty_memory_store_get_type() callconv(.C) G.gsize {
    if (G.g_once_init_enter(&belty_memory_store_type_id) != 0) {
        const g_define_type_id = G.g_type_register_static_simple(G.G_TYPE_OBJECT, G.g_intern_static_string("BeltyMemoryStore"), @sizeOf(BeltyMemoryStoreClass), belty_memory_store_class_intern_init, @sizeOf(BeltyMemoryStore), belty_memory_store_init, @intToEnum(G.GTypeFlags, 0));
        BeltyMemoryStore_private_offset = G.g_type_add_instance_private(g_define_type_id, @sizeOf(BeltyMemoryStorePrivate));
        G.g_type_add_interface_static(g_define_type_id, G.gtk_tree_model_get_type(), &.{ .interface_init = belty_memory_store_list_model_init, .interface_finalize = null, .interface_data = null });
        G.g_once_init_leave(&belty_memory_store_type_id, g_define_type_id);
    }
    return belty_memory_store_type_id;
}
fn belty_memory_store_new() ?*BeltyMemoryStore {
    return @ptrCast(*BeltyMemoryStore, @alignCast(@alignOf(BeltyMemoryStore), G.g_object_new(belty_memory_store_get_type(), null)));
}

fn activate(app: *G.GtkApplication, user_data: G.gpointer) void {
    const window = @ptrCast(*G.GtkWindow, G.gtk_application_window_new(app));

    if (false) {
        const instrs_store = gtk_list_store_new(3, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING);
        {
            var iter: GtkTreeIter = undefined;
            gtk_list_store_append(instrs_store, &iter);
            gtk_list_store_set(instrs_store, &iter, instrs_columns.addr, "0x0001", instrs_columns.raw, "0xabcdef", instrs_columns.disasm, "foo", instrs_columns.last);
        }

        const instrs = @ptrCast(*GtkTreeView, gtk_tree_view_new_with_model(@ptrCast(*GtkTreeModel, instrs_store)));
        {
            const renderer = gtk_cell_renderer_text_new();
            const column = gtk_tree_view_column_new_with_attributes("Addr", renderer, "text", instrs_columns.addr, @as(?*c_void, null));
            _ = gtk_tree_view_append_column(instrs, column);
        }
        {
            const renderer = gtk_cell_renderer_text_new();
            const column = gtk_tree_view_column_new_with_attributes("Raw", renderer, "text", instrs_columns.raw, @as(?*c_void, null));
            _ = gtk_tree_view_append_column(instrs, column);
        }
        {
            const renderer = gtk_cell_renderer_text_new();
            const column = gtk_tree_view_column_new_with_attributes("Disasm", renderer, "text", instrs_columns.disasm, @as(?*c_void, null));
            _ = gtk_tree_view_append_column(instrs, column);
        }

        const belt_store = gtk_list_store_new(2, G_TYPE_INT, G_TYPE_STRING);
        {
            var iter: GtkTreeIter = undefined;
            gtk_list_store_append(belt_store, &iter);
            gtk_list_store_set(belt_store, &iter, @as(c_int, 0), @as(c_int, 0), @as(c_int, 1), "0xabcdef", @as(c_int, -1));
        }

        const belt = @ptrCast(*GtkTreeView, gtk_tree_view_new_with_model(@ptrCast(*GtkTreeModel, belt_store)));
        {
            const renderer = gtk_cell_renderer_text_new();
            const column = gtk_tree_view_column_new_with_attributes("#", renderer, "text", @as(c_int, 0), @as(?*c_void, null));
            _ = gtk_tree_view_append_column(belt, column);
        }
        {
            const renderer = gtk_cell_renderer_text_new();
            const column = gtk_tree_view_column_new_with_attributes("Value", renderer, "text", @as(c_int, 1), @as(?*c_void, null));
            _ = gtk_tree_view_append_column(belt, column);
        }

        const paned = @ptrCast(*GtkPaned, gtk_paned_new(.GTK_ORIENTATION_HORIZONTAL));
        gtk_paned_set_start_child(paned, @ptrCast(*GtkWidget, instrs));
        gtk_paned_set_resize_start_child(paned, 1);
        gtk_paned_set_shrink_start_child(paned, 1);
        gtk_paned_set_end_child(paned, @ptrCast(*GtkWidget, belt));
        gtk_paned_set_resize_end_child(paned, 1);
        gtk_paned_set_shrink_end_child(paned, 1);
    }

    const memory_store = belty_memory_store_new();

    const memory = @ptrCast(*G.GtkTreeView, G.gtk_tree_view_new_with_model(@ptrCast(*G.GtkTreeModel, memory_store)));
    {
        const renderer = G.gtk_cell_renderer_text_new();
        const column = G.gtk_tree_view_column_new_with_attributes("Addr", renderer, "text", @as(c_int, 0), @as(?*c_void, null));
        _ = G.gtk_tree_view_append_column(memory, column);
    }
    {
        const renderer = G.gtk_cell_renderer_text_new();
        const column = G.gtk_tree_view_column_new_with_attributes("Raw", renderer, "text", @as(c_int, 1), @as(?*c_void, null));
        _ = G.gtk_tree_view_append_column(memory, column);
    }

    G.gtk_window_set_child(window, @ptrCast(*G.GtkWidget, memory));
    G.gtk_window_present(window);
}

pub fn main() u8 {
    var app = G.gtk_application_new("belt.cpu", .G_APPLICATION_FLAGS_NONE);
    defer G.g_object_unref(app);

    _ = G.g_signal_connect_data(app, "activate", @ptrCast(G.GCallback, activate), null, null, @intToEnum(G.GConnectFlags, 0));
    const status = G.g_application_run(@ptrCast(*G.GApplication, app), 0, null);

    return @intCast(u8, status);
}
