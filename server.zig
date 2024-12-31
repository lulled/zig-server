const std = @import("std");
const os = std.os;
const net = std.net;

pub fn main() !void {
    // Create socket
    const server_fd = try os.socket(os.AF.INET, os.SOCK.STREAM, os.IPPROTO.TCP);
    defer os.closeSocket(server_fd);

    // Set socket options for reuse
    try os.setsockopt(server_fd, os.SOL.SOCKET, os.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));

    // Create address
    // const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 8080);  //
    const address = net.Address.initIp4(.{ 0, 0, 0, 0 }, 8080);
    const sock_addr = address.any;
    const sock_len = address.getOsSockLen();

    // Bind
    try os.bind(server_fd, &sock_addr, sock_len);

    // Listen
    try os.listen(server_fd, 128);
    std.debug.print("Server listening on 127.0.0.1:8080\n", .{});

    while (true) {
        var client_addr: os.sockaddr = undefined;
        var client_addr_len: os.socklen_t = @sizeOf(os.sockaddr);

        const client_fd = try os.accept(server_fd, &client_addr, &client_addr_len, 0 // flags
        );

        try handleClient(client_fd);
    }
}

fn handleClient(client_fd: os.socket_t) !void {
    defer os.closeSocket(client_fd);

    var buf: [1024]u8 = undefined;

    while (true) {
        const bytes_read = try os.read(client_fd, &buf);
        if (bytes_read == 0) break;

        std.debug.print("Received: {s}\n", .{buf[0..bytes_read]});
        std.debug.print("Echoed back: {s}\n", .{buf[0..bytes_read]});

        _ = try os.write(client_fd, buf[0..bytes_read]);
    }

    std.debug.print("Client disconnected\n", .{});
}
