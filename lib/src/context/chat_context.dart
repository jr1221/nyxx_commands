import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

import '../commands/chat_command.dart';
import '../util/component_wrappers.dart';
import 'base.dart';

/// Represents a context in which a [ChatCommand] was invoked.
///
/// You might also be interested in:
/// - [MessageChatContext], for chat commands invoked from text messages;
/// - [InteractionChatContext], for chat commands invoked from slash commands.
abstract class IChatContextData implements ICommandContextData {
  @override
  ChatCommand get command;
}

/// Represents a context within a running [ChatCommand].
abstract class IChatContext implements IChatContextData, ICommandContext {
  /// The arguments parsed from the user input.
  ///
  /// The arguments are ordered by the order in which they appear in the function declaration. Since
  /// slash commands can specify optional arguments in any order, optional arguments declared before
  /// the last provided argument will be set to their default value (or `null` if unspecified).
  ///
  /// You might also be interested in:
  /// - [ChatCommand.execute], the function that dictates the order in which arguments are provided;
  /// - [Converter], the means by which these arguments are parsed.
  // Arguments are only initialized during command execution, so we put them here to avoid them
  // being accessed before that.
  List<dynamic> get arguments;

  /// Set the arguments used by this context.
  ///
  /// Should not be used unless you are implementing your own command handler.
  set arguments(List<dynamic> value);
}

abstract class ChatContext extends ContextBase implements IChatContext {
  @override
  late final List<dynamic> arguments;

  @override
  final ChatCommand command;

  ChatContext({
    required this.command,
    required super.user,
    required super.member,
    required super.guild,
    required super.channel,
    required super.commands,
    required super.client,
  });
}

/// Represents a context in which a [ChatCommand] was invoked from a text message.
///
/// You might also be interested in:
/// - [InteractionChatContext], for chat commands invoked from slash commands.
class MessageChatContext extends ChatContext with ComponentWrappersMixin {
  /// The message that triggered this command.
  final IMessage message;

  /// The prefix that was used to invoke this command.
  ///
  /// You might also be interested in:
  /// - [CommandsPlugin.prefix], the function called to determine the prefix to use for a given
  ///   message.
  final String prefix;

  /// The unparsed arguments from the message.
  ///
  /// This is the content of the message stripped of the [prefix] and the full command name.
  ///
  /// You might also be interested in:
  /// - [arguments], for getting the parsed arguments from this context.
  final String rawArguments;

  /// Create a new [MessageChatContext].
  MessageChatContext({
    required this.message,
    required this.prefix,
    required this.rawArguments,
    required super.command,
    required super.user,
    required super.member,
    required super.guild,
    required super.channel,
    required super.commands,
    required super.client,
  });

  @override
  Future<IMessage> respond(
    MessageBuilder builder, {
    bool private = false,
    bool mention = true,
  }) async {
    if (private) {
      return user.sendMessage(builder);
    } else {
      return await channel.sendMessage(builder
        ..replyBuilder = ReplyBuilder.fromMessage(message)
        ..allowedMentions ??= (AllowedMentions()
          ..allow(
            reply: mention,
            everyone: true,
            roles: true,
            users: true,
          )));
    }
  }
}

/// Represents a context in which a [ChatCommand] was invoked from an interaction.
///
/// You might also be interested in:
/// - [MessageChatContext], for chat commands invoked from text messages.
class InteractionChatContext extends ChatContext
    with InteractionRespondMixin, ComponentWrappersMixin
    implements IInteractionCommandContext {
  @override
  final ISlashCommandInteraction interaction;

  @override
  final ISlashCommandInteractionEvent interactionEvent;

  /// The unparsed arguments from the interaction.
  ///
  /// You might also be interested in:
  /// - [arguments], for getting the parsed arguments from this context.
  final Map<String, dynamic> rawArguments;

  /// Create a new [InteractionChatContext].
  InteractionChatContext({
    required this.rawArguments,
    required this.interaction,
    required this.interactionEvent,
    required super.command,
    required super.user,
    required super.member,
    required super.guild,
    required super.channel,
    required super.commands,
    required super.client,
  });
}
