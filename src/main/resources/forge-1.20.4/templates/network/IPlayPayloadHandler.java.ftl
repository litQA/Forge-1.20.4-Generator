package ${package}.network;

/**
 * Handles a decoded network message on the logical thread supplied by PlayPayloadContext.
 */
@FunctionalInterface
public interface IPlayPayloadHandler<T> {
	void handle(T message, PlayPayloadContext context);
}
